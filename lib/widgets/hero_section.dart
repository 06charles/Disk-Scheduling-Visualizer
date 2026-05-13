import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onStart;

  const HeroSection({Key? key, required this.onStart}) : super(key: key);

  @override
  _HeroSectionState createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DISK SCHEDULING VISUALIZER',
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Interactive Seek Time Analyzer for Operating Systems',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(
              fontSize: 18,
              color: Colors.black54,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 40),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF39FF14).withOpacity(0.8),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Color(0xFF39FF14)),
                    const SizedBox(width: 10),
                    Text(
                      'START SIMULATION',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF39FF14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
