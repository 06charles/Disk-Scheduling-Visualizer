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
}
