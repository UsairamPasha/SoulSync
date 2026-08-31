import 'package:flutter/material.dart';

/// Centralized Elevation and Shadow Tokens for SoulSync.
abstract class AppShadows {
  // Small Shadow
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // Medium Shadow
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // Large Shadow
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x29000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Floating Component Shadow
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x3D7C5CFC),
      blurRadius: 20,
      spreadRadius: -2,
      offset: Offset(0, 8),
    ),
  ];

  // Music & Card Glow Shadow
  static const List<BoxShadow> cardGlow = [
    BoxShadow(
      color: Color(0x1F7C5CFC),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
