import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/glass_card.dart';

class SeekChart extends StatefulWidget {
  final List<int> seekSequence;
  final int maxDiskSize;
  final VoidCallback onAnimationComplete;

  const SeekChart({
    Key? key,
    required this.seekSequence,
    required this.maxDiskSize,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  _SeekChartState createState() => _SeekChartState();
}

class _SeekChartState extends State<SeekChart> {
  List<FlSpot> _visibleSpots = [];
  Timer? _timer;
  int _currentIndex = 0;
  bool _isPaused = false;
  double _speedMs = 500;
  int _currentHead = 0;

  @override
  void initState() {
    super.initState();
    _currentHead = widget.seekSequence.isNotEmpty ? widget.seekSequence[0] : 0;
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant SeekChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seekSequence != oldWidget.seekSequence ||
        widget.maxDiskSize != oldWidget.maxDiskSize) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    setState(() {
      _visibleSpots = [];
      _currentIndex = 0;
      _isPaused = false;
      _currentHead = widget.seekSequence.isNotEmpty ? widget.seekSequence[0] : 0;
    });

    if (widget.seekSequence.isEmpty) return;
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    if (_isPaused) return;

    _timer = Timer(Duration(milliseconds: _speedMs.toInt()), _tick);
  }

  void _tick() async {
    if (_currentIndex < widget.seekSequence.length) {
      setState(() {
        _currentHead = widget.seekSequence[_currentIndex];
        _visibleSpots.add(FlSpot(
          _currentIndex.toDouble(),
          _currentHead.toDouble(),
        ));
        _currentIndex++;
      });
      _scheduleNextTick();
    } else {
      widget.onAnimationComplete();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (!_isPaused) {
      _scheduleNextTick();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: Theme.of(context).primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VISUALIZATION',
                style: GoogleFonts.orbitron(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text('Speed:', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  SizedBox(
                    width: 100,
                    child: Slider(
                      value: _speedMs,
                      min: 100,
                      max: 2000,
                      divisions: 19,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (val) {
                        setState(() {
                          _speedMs = val;
                        });
                        if (!_isPaused) _scheduleNextTick();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: _currentIndex < widget.seekSequence.length ? _togglePause : null,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'Track: $_currentHead',
                      style: GoogleFonts.robotoMono(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (widget.seekSequence.length > 0 ? widget.seekSequence.length - 1 : 1).toDouble(),
                minY: 0,
                maxY: widget.maxDiskSize.toDouble(),
                  gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.black12,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.black12,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text('Step', style: const TextStyle(color: Colors.black54)),
                    axisNameSize: 20,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.black45));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text('Track Number', style: const TextStyle(color: Colors.black54)),
                    axisNameSize: 30,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: const TextStyle(color: Colors.black45));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black26),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _visibleSpots,
                    isCurved: false,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: index == _visibleSpots.length - 1 ? 6 : 4,
                          color: Theme.of(context).primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.black,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.3),
                          Theme.of(context).primaryColor.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
          ),
        ],
      ),
    );
  }
}
