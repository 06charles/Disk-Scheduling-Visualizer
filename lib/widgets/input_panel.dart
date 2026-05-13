import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class InputPanel extends StatelessWidget {
  final TextEditingController queueController;
  final TextEditingController headController;
  final TextEditingController maxSizeController;
  final String? selectedAlgorithm;
  final String? selectedDirection;
  final Function(String) onAlgorithmChanged;
  final Function(String) onDirectionChanged;
  final VoidCallback onRun;
  final VoidCallback onCompare;
  final VoidCallback onReset;

  const InputPanel({
    Key? key,
    required this.queueController,
    required this.headController,
    required this.maxSizeController,
    required this.selectedAlgorithm,
    required this.selectedDirection,
    required this.onAlgorithmChanged,
    required this.onDirectionChanged,
    required this.onRun,
    required this.onCompare,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: const Color(0xFF00BFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PARAMETERS',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00BFFF),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: queueController,
            label: 'Request Queue (comma separated)',
            icon: Icons.list,
            hintText: 'e.g. 82, 170, 43, 140, 24, 16, 190',
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: headController,
                  label: 'Initial Head',
                  icon: Icons.my_location,
                  hintText: 'e.g. 50',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  controller: maxSizeController,
                  label: 'Disk Size',
                  icon: Icons.data_usage,
                  hintText: 'e.g. 200',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildAlgorithmDropdown()),
              const SizedBox(width: 15),
              Expanded(child: _buildDirectionDropdown()),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('RUN', onRun, const Color(0xFF39FF14)),
              _buildButton('COMPARE ALL', onCompare, const Color(0xFFFFD700)),
              _buildButton('RESET', onReset, const Color(0xFFFF4C4C)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38),
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: Icon(icon, color: const Color(0xFF00BFFF)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
      ),
    );
  }

  Widget _buildAlgorithmDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedAlgorithm,
      dropdownColor: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      style: const TextStyle(color: Colors.black87),
      hint: const Text('Algorithm', style: TextStyle(color: Colors.black54)),
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
      ),
      items: ['FCFS', 'SSTF', 'SCAN', 'C-SCAN', 'LOOK', 'C-LOOK']
          .map((algo) => DropdownMenuItem(value: algo, child: Text(algo)))
          .toList(),
      onChanged: (val) {
        if (val != null) onAlgorithmChanged(val);
      },
    );
  }

  Widget _buildDirectionDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDirection,
      dropdownColor: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(20),
      style: const TextStyle(color: Colors.black87),
      hint: const Text('Direction', style: TextStyle(color: Colors.black54)),
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
      ),
      items: ['Left', 'Right']
          .map((dir) => DropdownMenuItem(value: dir, child: Text(dir)))
          .toList(),
      onChanged: (val) {
        if (val != null) onDirectionChanged(val);
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.7),
        foregroundColor: color,
        elevation: 0,
        side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
      ),
    );
  }
}
