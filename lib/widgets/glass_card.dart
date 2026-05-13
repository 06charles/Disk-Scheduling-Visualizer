import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color borderColor;
  final double borderRadius;

  const GlassCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24.0),
    this.margin = const EdgeInsets.all(8.0),
    this.borderColor = const Color(0xFFFFFFFF), // Use white for frosted edge
    this.borderRadius = 32.0, // More rounded Apple-like corners
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0), // High blur for liquid effect
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.5), // Inner highlight border
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.2),
                ],
                stops: const [0.1, 1.0],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
