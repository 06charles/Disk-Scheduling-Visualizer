class SimulationResult {
  final String algorithmName;
  final List<int> seekSequence;
  final int totalHeadMovement;
  final double averageSeekTime;

  SimulationResult({
    required this.algorithmName,
    required this.seekSequence,
    required this.totalHeadMovement,
    required this.averageSeekTime,
  });
}
