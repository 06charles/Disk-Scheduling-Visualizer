import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({Key? key}) : super(key: key);

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
        ],
      ),
    );
  }
}
