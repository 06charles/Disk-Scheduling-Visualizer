import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/simulation_result.dart';
import '../widgets/glass_card.dart';

class ComparisonChart extends StatelessWidget {
  final List<SimulationResult> results;

  const ComparisonChart({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    double maxMovement = 0;
    for (var r in results) {
      if (r.totalHeadMovement > maxMovement) {
        maxMovement = r.totalHeadMovement.toDouble();
      }
    }

    return GlassCard(
      borderColor: const Color(0xFFFFD700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'COMPARISON DASHBOARD',
            style: GoogleFonts.orbitron(
              color: const Color(0xFFFFD700),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxMovement * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white.withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final name = results[group.x].algorithmName;
                      return BarTooltipItem(
                        '$name\n',
                        const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${rod.toY.toInt()} Cylinders',
                            style: TextStyle(
                              color: rod.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            results[value.toInt()].algorithmName,
                            style: GoogleFonts.robotoMono(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.black45, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: results.asMap().entries.map((entry) {
                  int idx = entry.key;
                  SimulationResult result = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: result.totalHeadMovement.toDouble(),
                        color: _getColorForIndex(idx),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxMovement * 1.2,
                          color: Colors.black12,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 800),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 20),
          _buildDataTable(),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    List<Color> colors = [
      const Color(0xFF39FF14), // Neon Green
      const Color(0xFF00BFFF), // Electric Blue
      const Color(0xFFFFD700), // Warning Yellow
      const Color(0xFFFF4C4C), // Soft Red
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];
    return colors[index % colors.length];
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: GoogleFonts.orbitron(color: Colors.black87, fontWeight: FontWeight.bold),
        dataTextStyle: GoogleFonts.robotoMono(color: Colors.black54),
        columns: const [
          DataColumn(label: Text('Algorithm')),
          DataColumn(label: Text('Total Movement')),
          DataColumn(label: Text('Avg Seek Time')),
        ],
        rows: results.map((r) {
          return DataRow(
            cells: [
              DataCell(Text(r.algorithmName, style: const TextStyle(color: Colors.black87))),
              DataCell(Text(r.totalHeadMovement.toString())),
              DataCell(Text('${r.averageSeekTime.toStringAsFixed(2)} ms')),
            ],
          );
        }).toList(),
      ),
    );
  }
}
