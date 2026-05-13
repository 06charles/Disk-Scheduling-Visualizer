import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/simulation_result.dart';
import 'glass_card.dart';

class ResultCard extends StatelessWidget {
  final SimulationResult result;

  const ResultCard({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: const Color(0xFF39FF14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RESULTS: ${result.algorithmName}',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFF39FF14),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.analytics_outlined, color: Color(0xFF39FF14)),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatRow('Total Head Movement:', '${result.totalHeadMovement} Cylinders'),
          const SizedBox(height: 10),
          _buildStatRow('Average Seek Time:', '${result.averageSeekTime.toStringAsFixed(2)} ms'),
          const SizedBox(height: 20),
          Text(
            'Seek Sequence:',
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Text(
              result.seekSequence.join(' → '),
              style: GoogleFonts.robotoMono(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
