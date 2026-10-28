/// Frosted glassmorphic container with neon borders and backdrop blur.
library;

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;
  final double blurSigma;
  final List<BoxShadow>? extraShadows;

  const GlassPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 20,
    this.borderColor = const Color(0xFF00E5FF),
    this.backgroundColor = const Color(0x33102030),
    this.blurSigma = 10,
    this.extraShadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          ...?extraShadows,
          BoxShadow(
            color: borderColor.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: borderColor.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            color: backgroundColor,
            child: child,
          ),
        ),
      ),
    );
  }
}
