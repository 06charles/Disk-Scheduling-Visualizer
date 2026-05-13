import '../models/simulation_result.dart';

class DiskSchedulingAlgorithms {
  static SimulationResult runFCFS(List<int> queue, int head) {
    List<int> sequence = [head, ...queue];
    int totalMovement = 0;
    
    for (int i = 0; i < sequence.length - 1; i++) {
      totalMovement += (sequence[i] - sequence[i + 1]).abs();
    }
    
    return SimulationResult(
      algorithmName: "FCFS",
      seekSequence: sequence,
      totalHeadMovement: totalMovement,
      averageSeekTime: queue.isEmpty ? 0 : totalMovement / queue.length,
    );
  }

  static SimulationResult runSSTF(List<int> queue, int head) {
    List<int> remaining = List.from(queue);
    List<int> sequence = [head];
    int currentHead = head;
    int totalMovement = 0;

    while (remaining.isNotEmpty) {
      int closestIdx = 0;
      int minDistance = (currentHead - remaining[0]).abs();
      
      for (int i = 1; i < remaining.length; i++) {
        int distance = (currentHead - remaining[i]).abs();
        if (distance < minDistance) {
          minDistance = distance;
          closestIdx = i;
        }
      }
      
      int nextHead = remaining[closestIdx];
      sequence.add(nextHead);
      totalMovement += minDistance;
      currentHead = nextHead;
      remaining.removeAt(closestIdx);
    }

    return SimulationResult(
      algorithmName: "SSTF",
      seekSequence: sequence,
      totalHeadMovement: totalMovement,
      averageSeekTime: queue.isEmpty ? 0 : totalMovement / queue.length,
    );
  }

  static SimulationResult runSCAN(List<int> queue, int head, int maxDiskSize, String direction) {
    List<int> sequence = [head];
    int totalMovement = 0;
    List<int> left = [];
    List<int> right = [];

    if (direction == "Left") {
      left.add(0);
    } else {
      right.add(maxDiskSize - 1);
    }

    for (int req in queue) {
      if (req < head) left.add(req);
      if (req > head) right.add(req);
      if (req == head) {
        // If request is at current head, just add to sequence directly or skip. Let's add it to the primary direction list.
        if (direction == "Left") left.add(req);
        else right.add(req);
      }
    }

    left.sort();
    right.sort();

    int currentHead = head;
    List<int> runList = [];

    if (direction == "Left") {
      for (int i = left.length - 1; i >= 0; i--) runList.add(left[i]);
      for (int i = 0; i < right.length; i++) runList.add(right[i]);
    } else {
      for (int i = 0; i < right.length; i++) runList.add(right[i]);
      for (int i = left.length - 1; i >= 0; i--) runList.add(left[i]);
    }

    for (int nextHead in runList) {
      sequence.add(nextHead);
      totalMovement += (currentHead - nextHead).abs();
      currentHead = nextHead;
    }

    return SimulationResult(
      algorithmName: "SCAN",
      seekSequence: sequence,
      totalHeadMovement: totalMovement,
      averageSeekTime: queue.isEmpty ? 0 : totalMovement / queue.length,
    );
  }

  static SimulationResult runCSCAN(List<int> queue, int head, int maxDiskSize, String direction) {
    List<int> sequence = [head];
    int totalMovement = 0;
    List<int> left = [];
    List<int> right = [];

    left.add(0);
    right.add(maxDiskSize - 1);

    for (int req in queue) {
      if (req < head) left.add(req);
      if (req > head) right.add(req);
      if (req == head) {
        if (direction == "Left") left.add(req);
        else right.add(req);
      }
    }

    left.sort();
    right.sort();

    int currentHead = head;
    List<int> runList = [];

    if (direction == "Right") {
      for (int i = 0; i < right.length; i++) runList.add(right[i]);
      for (int i = 0; i < left.length; i++) runList.add(left[i]);
    } else {
      for (int i = left.length - 1; i >= 0; i--) runList.add(left[i]);
      for (int i = right.length - 1; i >= 0; i--) runList.add(right[i]);
    }

    for (int nextHead in runList) {
      sequence.add(nextHead);
      totalMovement += (currentHead - nextHead).abs();
      currentHead = nextHead;
    }

    return SimulationResult(
      algorithmName: "C-SCAN",
      seekSequence: sequence,
      totalHeadMovement: totalMovement,
      averageSeekTime: queue.isEmpty ? 0 : totalMovement / queue.length,
    );
  }

  static SimulationResult runLOOK(List<int> queue, int head, String direction) {
    List<int> sequence = [head];
    int totalMovement = 0;
    List<int> left = [];
    List<int> right = [];

    for (int req in queue) {
      if (req < head) left.add(req);
      if (req > head) right.add(req);
      if (req == head) {
        if (direction == "Left") left.add(req);
        else right.add(req);
      }
    }

    left.sort();
    right.sort();

    int currentHead = head;
    List<int> runList = [];

    if (direction == "Left") {
      for (int i = left.length - 1; i >= 0; i--) runList.add(left[i]);
      for (int i = 0; i < right.length; i++) runList.add(right[i]);
    } else {
      for (int i = 0; i < right.length; i++) runList.add(right[i]);
      for (int i = left.length - 1; i >= 0; i--) runList.add(left[i]);
    }

    for (int nextHead in runList) {
      sequence.add(nextHead);
      totalMovement += (currentHead - nextHead).abs();
      currentHead = nextHead;
    }

    return SimulationResult(
      algorithmName: "LOOK",
      seekSequence: sequence,
      totalHeadMovement: totalMovement,
      averageSeekTime: queue.isEmpty ? 0 : totalMovement / queue.length,
    );
  }

  static SimulationResult runCLOOK(List<int> queue, int head, String direction) {
    List<int> sequence = [head];
    int totalMovement = 0;
    List<int> left = [];
    List<int> right = [];

    for (int req in queue) {
      if (req < head) left.add(req);
      if (req > head) right.add(req);
      if (req == head) {
        if (direction == "Left") left.add(req);
        else right.add(req);
      }
    }

    left.sort();
    right.sort();

    int currentHead = head;
    List<int> runList = [];

    if (direction == "Right") {
      for (int i = 0; i < right.length; i++) runList.add(right[i]);
      for (int i = 0; i < left.length; i++) runList.add(left[i]);
    } else {
      for (int i = left.length - 1; i >= 0; i--) runList.add(left[i]);
      for (int i = right.length - 1; i >= 0; i--) runList.add(right[i]);
    }

    for (int nextHead in runList) {
      sequence.add(nextHead);
      totalMovement += (currentHead - nextHead).abs();
      currentHead = nextHead;
    }

    return SimulationResult(
      algorithmName: "C-LOOK",
      seekSequence: sequence,
      totalHeadMovement: totalMovement,
      averageSeekTime: queue.isEmpty ? 0 : totalMovement / queue.length,
    );
  }

  static List<SimulationResult> runAll(List<int> queue, int head, int maxDiskSize, String direction) {
    return [
      runFCFS(queue, head),
      runSSTF(queue, head),
      runSCAN(queue, head, maxDiskSize, direction),
      runCSCAN(queue, head, maxDiskSize, direction),
      runLOOK(queue, head, direction),
      runCLOOK(queue, head, direction),
    ];
  }
}
