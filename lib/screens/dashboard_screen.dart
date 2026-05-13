import 'package:flutter/material.dart';

import '../algorithms/disk_scheduling.dart';
import '../charts/comparison_chart.dart';
import '../charts/seek_chart.dart';
import '../models/simulation_result.dart';
import '../widgets/hero_section.dart';
import '../widgets/input_panel.dart';
import '../widgets/result_card.dart';
import '../utils/pdf_generator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _queueController = TextEditingController();
  final TextEditingController _headController = TextEditingController();
  final TextEditingController _maxSizeController = TextEditingController();

  String? _selectedAlgorithm;
  String? _selectedDirection;

  SimulationResult? _currentResult;
  List<SimulationResult>? _allResults;
  bool _showComparison = false;
  bool _isSimulating = false;
  
  final ScrollController _scrollController = ScrollController();

  void _runSimulation() {
    FocusScope.of(context).unfocus();
    if (_selectedAlgorithm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an algorithm.')),
      );
      return;
    }
    if ((_selectedAlgorithm == 'SCAN' || _selectedAlgorithm == 'C-SCAN' || _selectedAlgorithm == 'LOOK' || _selectedAlgorithm == 'C-LOOK') && _selectedDirection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a direction for SCAN/LOOK algorithms.')),
      );
      return;
    }
    if (_queueController.text.isEmpty || _headController.text.isEmpty || _maxSizeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all parameters.')),
      );
      return;
    }
    try {
      List<int> queue = _queueController.text
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
      int head = int.parse(_headController.text.trim());
      int maxSize = int.parse(_maxSizeController.text.trim());

      SimulationResult res;
      switch (_selectedAlgorithm) {
        case 'FCFS':
          res = DiskSchedulingAlgorithms.runFCFS(queue, head);
          break;
        case 'SSTF':
          res = DiskSchedulingAlgorithms.runSSTF(queue, head);
          break;
        case 'SCAN':
          res = DiskSchedulingAlgorithms.runSCAN(queue, head, maxSize, _selectedDirection!);
          break;
        case 'C-SCAN':
          res = DiskSchedulingAlgorithms.runCSCAN(queue, head, maxSize, _selectedDirection!);
          break;
        case 'LOOK':
          res = DiskSchedulingAlgorithms.runLOOK(queue, head, _selectedDirection!);
          break;
        case 'C-LOOK':
          res = DiskSchedulingAlgorithms.runCLOOK(queue, head, _selectedDirection!);
          break;
        default:
          res = DiskSchedulingAlgorithms.runFCFS(queue, head);
      }

      setState(() {
        _currentResult = res;
        _showComparison = false;
        _isSimulating = true;
      });

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input. Please enter valid integers.')),
      );
    }
  }

  void _compareAll() {
    FocusScope.of(context).unfocus();
    if (_selectedDirection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a direction for comparison.')),
      );
      return;
    }
    if (_queueController.text.isEmpty || _headController.text.isEmpty || _maxSizeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all parameters.')),
      );
      return;
    }
    try {
      List<int> queue = _queueController.text
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
      int head = int.parse(_headController.text.trim());
      int maxSize = int.parse(_maxSizeController.text.trim());

      List<SimulationResult> results = DiskSchedulingAlgorithms.runAll(
        queue,
        head,
        maxSize,
        _selectedDirection!,
      );

      setState(() {
        _allResults = results;
        _showComparison = true;
        _currentResult = null;
        _isSimulating = false;
      });

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid input. Please enter valid integers.')),
      );
    }
  }

  void _reset() {
    setState(() {
      _queueController.clear();
      _headController.clear();
      _maxSizeController.clear();
      _selectedAlgorithm = null;
      _selectedDirection = null;
      _currentResult = null;
      _allResults = null;
      _showComparison = false;
      _isSimulating = false;
    });
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _queueController.dispose();
    _headController.dispose();
    _maxSizeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by main.dart background
      body: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          // Animated Grid lines could go here
          

          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? MediaQuery.of(context).size.width * 0.1 : 20.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  HeroSection(
                    onStart: () {
                      _scrollController.animateTo(
                        400,
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  InputPanel(
                    queueController: _queueController,
                    headController: _headController,
                    maxSizeController: _maxSizeController,
                    selectedAlgorithm: _selectedAlgorithm,
                    selectedDirection: _selectedDirection,
                    onAlgorithmChanged: (val) => setState(() => _selectedAlgorithm = val),
                    onDirectionChanged: (val) => setState(() => _selectedDirection = val),
                    onRun: _runSimulation,
                    onCompare: _compareAll,
                    onReset: _reset,
                  ),
                  const SizedBox(height: 40),
                  
                  // Visualizer Section
                  if (_currentResult != null) ...[
                    AnimatedOpacity(
                      opacity: _currentResult != null ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        children: [
                          ResultCard(result: _currentResult!),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                List<int> queue = _queueController.text.split(',').map((e) => int.parse(e.trim())).toList();
                                int head = int.parse(_headController.text.trim());
                                int maxSize = int.parse(_maxSizeController.text.trim());
                                PdfGenerator.generateAndPrintPdf(
                                  algorithm: _selectedAlgorithm!,
                                  result: _currentResult!,
                                  queue: queue,
                                  initialHead: head,
                                  maxDiskSize: maxSize,
                                );
                              },
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Export Report'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.7),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            height: 400,
                            child: SeekChart(
                              seekSequence: _currentResult!.seekSequence,
                              maxDiskSize: int.tryParse(_maxSizeController.text) ?? 200,
                              onAnimationComplete: () {
                                setState(() {
                                  _isSimulating = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Comparison Dashboard
                  if (_showComparison && _allResults != null) ...[
                    AnimatedOpacity(
                      opacity: _showComparison ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: SizedBox(
                        height: 600,
                        child: ComparisonChart(results: _allResults!),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100), // Padding at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
