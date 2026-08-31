import 'package:flutter/material.dart';

/// Centralized Border Radius Tokens for SoulSync.
abstract class AppRadius {
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 999.0;

  // Radius object shortcuts
  static const Radius radiusXS = Radius.circular(xs);
  static const Radius radiusSM = Radius.circular(sm);
  static const Radius radiusMD = Radius.circular(md);
  static const Radius radiusLG = Radius.circular(lg);
  static const Radius radiusXL = Radius.circular(xl);
  static const Radius radiusXXL = Radius.circular(xxl);

  // BorderRadius object shortcuts
  static const BorderRadius borderNone = BorderRadius.zero;
  static const BorderRadius borderXS = BorderRadius.all(radiusXS);
  static const BorderRadius borderSM = BorderRadius.all(radiusSM);
  static const BorderRadius borderMD = BorderRadius.all(radiusMD);
  static const BorderRadius borderLG = BorderRadius.all(radiusLG);
  static const BorderRadius borderXL = BorderRadius.all(radiusXL);
  static const BorderRadius borderXXL = BorderRadius.all(radiusXXL);
  static const BorderRadius borderFull =
      BorderRadius.all(Radius.circular(full));
}
