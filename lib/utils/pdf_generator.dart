import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/simulation_result.dart';

class PdfGenerator {
  static Future<void> generateAndPrintPdf({
    required String algorithm,
    required SimulationResult result,
    required List<int> queue,
    required int initialHead,
    required int maxDiskSize,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(algorithm),
            pw.SizedBox(height: 20),
            _buildSummaryInfo(queue, initialHead, maxDiskSize, result),
            pw.SizedBox(height: 20),
            _buildChart(context, result.seekSequence, maxDiskSize),
            pw.SizedBox(height: 20),
            _buildSequenceTable(result.seekSequence),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Disk_Scheduling_${algorithm}_Report.pdf',
    );
  }

  static pw.Widget _buildHeader(String algorithm) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Disk Scheduling Simulation Report',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Algorithm: $algorithm',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.Divider(thickness: 2),
      ],
    );
  }

  static pw.Widget _buildSummaryInfo(
    List<int> queue,
    int initialHead,
    int maxDiskSize,
    SimulationResult result,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Simulation Parameters', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 8),
          pw.Text('Initial Head Position: $initialHead'),
          pw.Text('Max Disk Size: $maxDiskSize'),
          pw.Text('Request Queue: ${queue.join(', ')}'),
          pw.SizedBox(height: 12),
          pw.Text('Results', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 8),
          pw.Text('Total Head Movement: ${result.totalHeadMovement} Tracks'),
          pw.Text('Average Seek Time: ${result.averageSeekTime.toStringAsFixed(2)} Tracks'),
        ],
      ),
    );
  }

  static pw.Widget _buildSequenceTable(List<int> sequence) {
    List<pw.TableRow> rows = [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue100),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Step', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Track Number', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Movement Distance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    ];

    int prevTrack = sequence.isNotEmpty ? sequence[0] : 0;
    
    for (int i = 0; i < sequence.length; i++) {
      int currentTrack = sequence[i];
      int movement = (currentTrack - prevTrack).abs();
      
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i % 2 == 0 ? PdfColors.white : PdfColors.grey50,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(i.toString()),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(currentTrack.toString()),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(i == 0 ? '0 (Initial)' : movement.toString()),
            ),
          ],
        ),
      );
      
      prevTrack = currentTrack;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Seek Sequence Path', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: rows,
        ),
      ],
    );
  }

  static pw.Widget _buildChart(pw.Context context, List<int> sequence, int maxDiskSize) {
    if (sequence.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Seek Sequence Chart', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 200,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.CustomPaint(
            painter: (PdfGraphics canvas, PdfPoint size) {
              final font = pw.Theme.of(context).defaultTextStyle.font!.getFont(context);
              
              const double leftMargin = 30.0;
              const double bottomMargin = 20.0;
              const double topMargin = 15.0;
              const double rightMargin = 10.0;
              
              final double drawWidth = size.x - leftMargin - rightMargin;
              final double drawHeight = size.y - topMargin - bottomMargin;
              
              // Draw Axis Titles
              canvas.setFillColor(PdfColors.black);
              canvas.drawString(font, 10, 'Track Number', 0, size.y - 8);
              canvas.drawString(font, 10, 'Step', leftMargin + drawWidth / 2 - 10, 2);

              // Draw grid lines and labels
              canvas.setStrokeColor(PdfColors.grey200);
              canvas.setLineWidth(1);
              
              int numXLines = sequence.length > 1 ? sequence.length - 1 : 1;
              for (int i = 0; i <= numXLines; i++) {
                double x = leftMargin + (i / numXLines) * drawWidth;
                
                // Vertical grid line
                canvas.moveTo(x, bottomMargin);
                canvas.lineTo(x, bottomMargin + drawHeight);
                canvas.strokePath();
                
                // X-axis number
                canvas.setFillColor(PdfColors.black);
                canvas.drawString(font, 8, i.toString(), x - 3, bottomMargin - 12);
              }
              
              int numYLines = 10;
              for (int i = 0; i <= numYLines; i++) {
                double y = bottomMargin + (i / numYLines) * drawHeight;
                int trackValue = ((i / numYLines) * (maxDiskSize > 0 ? maxDiskSize : 1)).round();
                
                // Horizontal grid line
                canvas.setStrokeColor(PdfColors.grey200);
                canvas.moveTo(leftMargin, y);
                canvas.lineTo(leftMargin + drawWidth, y);
                canvas.strokePath();
                
                // Y-axis number
                canvas.setFillColor(PdfColors.black);
                canvas.drawString(font, 8, trackValue.toString(), 2, y - 3);
              }

              // Draw sequence line
              if (sequence.isNotEmpty) {
                canvas.setStrokeColor(PdfColors.blue);
                canvas.setLineWidth(2);
                
                for (int i = 0; i < sequence.length; i++) {
                  double x = leftMargin + (i / numXLines) * drawWidth;
                  double y = bottomMargin + (sequence[i] / (maxDiskSize > 0 ? maxDiskSize : 1)) * drawHeight;
                  
                  if (i == 0) {
                    canvas.moveTo(x, y);
                  } else {
                    canvas.lineTo(x, y);
                  }
                }
                canvas.strokePath();
                
                // Draw dots
                canvas.setFillColor(PdfColors.blue900);
                for (int i = 0; i < sequence.length; i++) {
                  double x = leftMargin + (i / numXLines) * drawWidth;
                  double y = bottomMargin + (sequence[i] / (maxDiskSize > 0 ? maxDiskSize : 1)) * drawHeight;
                  canvas.drawEllipse(x, y, 3, 3);
                  canvas.fillPath();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated by Disk Scheduling Visualizer & Analyzer',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
        ),
        pw.Text(
          'Date: ${DateTime.now().toLocal().toString().split('.')[0]}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
        ),
      ],
    );
  }

  static Future<void> generateComparisonPdf({
    required List<SimulationResult> results,
    required List<int> queue,
    required int initialHead,
    required int maxDiskSize,
  }) async {
    final doc = pw.Document();

    // Sort results by total head movement
    final sortedResults = List<SimulationResult>.from(results)
      ..sort((a, b) => a.totalHeadMovement.compareTo(b.totalHeadMovement));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader('Comparison of All Algorithms'),
            pw.SizedBox(height: 20),
            _buildComparisonSummary(queue, initialHead, maxDiskSize),
            pw.SizedBox(height: 20),
            _buildComparisonLeaderboard(sortedResults),
            pw.SizedBox(height: 30),
            _buildComparisonChart(context, sortedResults),
            pw.SizedBox(height: 30),
            _buildConclusion(sortedResults.first),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Disk_Scheduling_Comparison_Report.pdf',
    );
  }

  static pw.Widget _buildComparisonSummary(List<int> queue, int initialHead, int maxDiskSize) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Simulation Parameters', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 8),
          pw.Text('Initial Head Position: $initialHead'),
          pw.Text('Max Disk Size: $maxDiskSize'),
          pw.Text('Request Queue: ${queue.join(', ')}'),
        ],
      ),
    );
  }

  static pw.Widget _buildComparisonLeaderboard(List<SimulationResult> sortedResults) {
    List<pw.TableRow> rows = [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue100),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Rank', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Algorithm', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Total Head Movement', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Average Seek Time', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    ];

    for (int i = 0; i < sortedResults.length; i++) {
      final res = sortedResults[i];
      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: i == 0 ? PdfColors.green50 : (i % 2 == 0 ? PdfColors.white : PdfColors.grey50),
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('#${i + 1}'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(res.algorithmName, style: pw.TextStyle(fontWeight: i == 0 ? pw.FontWeight.bold : pw.FontWeight.normal)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(res.totalHeadMovement.toString(), style: pw.TextStyle(fontWeight: i == 0 ? pw.FontWeight.bold : pw.FontWeight.normal, color: i == 0 ? PdfColors.green900 : PdfColors.black)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(res.averageSeekTime.toStringAsFixed(2)),
            ),
          ],
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Performance Leaderboard', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: rows,
        ),
      ],
    );
  }

  static pw.Widget _buildComparisonChart(pw.Context context, List<SimulationResult> sortedResults) {
    if (sortedResults.isEmpty) return pw.SizedBox();

    int maxMovement = sortedResults.map((r) => r.totalHeadMovement).reduce((a, b) => a > b ? a : b);
    if (maxMovement == 0) maxMovement = 1;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Total Head Movement Chart', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 250,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.CustomPaint(
            painter: (PdfGraphics canvas, PdfPoint size) {
              final font = pw.Theme.of(context).defaultTextStyle.font!.getFont(context);
              
              const double leftMargin = 40.0;
              const double bottomMargin = 30.0;
              const double topMargin = 20.0;
              const double rightMargin = 20.0;
              
              final double drawWidth = size.x - leftMargin - rightMargin;
              final double drawHeight = size.y - topMargin - bottomMargin;

              // Draw Axis Titles
              canvas.setFillColor(PdfColors.black);
              canvas.drawString(font, 10, 'Total Head Movement', 0, size.y - 12);
              canvas.drawString(font, 10, 'Algorithms', leftMargin + drawWidth / 2 - 20, 2);

              // Y-axis grid lines and labels
              int numYLines = 5;
              for (int i = 0; i <= numYLines; i++) {
                double y = bottomMargin + (i / numYLines) * drawHeight;
                int trackValue = ((i / numYLines) * maxMovement).round();
                
                canvas.setStrokeColor(PdfColors.grey200);
                canvas.setLineWidth(1);
                canvas.moveTo(leftMargin, y);
                canvas.lineTo(leftMargin + drawWidth, y);
                canvas.strokePath();
                
                canvas.setFillColor(PdfColors.black);
                canvas.drawString(font, 8, trackValue.toString(), 5, y - 3);
              }

              // Draw bars
              final double barWidth = (drawWidth / sortedResults.length) * 0.6;
              final double spacing = (drawWidth / sortedResults.length) * 0.4;

              for (int i = 0; i < sortedResults.length; i++) {
                final res = sortedResults[i];
                double x = leftMargin + (spacing / 2) + i * (barWidth + spacing);
                double barHeight = (res.totalHeadMovement / maxMovement) * drawHeight;
                
                // Color the best algorithm differently
                canvas.setFillColor(i == 0 ? PdfColors.green : PdfColors.blue);
                canvas.drawRect(x, bottomMargin, barWidth, barHeight);
                canvas.fillPath();

                // Draw X-axis label (Algorithm Name)
                canvas.setFillColor(PdfColors.black);
                // Center the text under the bar
                canvas.drawString(font, 8, res.algorithmName, x + barWidth / 2 - (res.algorithmName.length * 2.5), bottomMargin - 15);
                
                // Draw value on top of bar
                canvas.drawString(font, 8, res.totalHeadMovement.toString(), x + barWidth / 2 - 5, bottomMargin + barHeight + 5);
              }
              
              // Draw Base line
              canvas.setStrokeColor(PdfColors.black);
              canvas.setLineWidth(1);
              canvas.moveTo(leftMargin, bottomMargin);
              canvas.lineTo(leftMargin + drawWidth, bottomMargin);
              canvas.strokePath();
              canvas.moveTo(leftMargin, bottomMargin);
              canvas.lineTo(leftMargin, bottomMargin + drawHeight);
              canvas.strokePath();
            },
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildConclusion(SimulationResult bestResult) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.green300),
      ),
      child: pw.Row(
        children: [
          pw.Text('Conclusion: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, color: PdfColors.green900)),
          pw.Expanded(
            child: pw.Text(
              'Based on the simulation, ${bestResult.algorithmName} is the optimal choice for this sequence with a total head movement of ${bestResult.totalHeadMovement} tracks.',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
