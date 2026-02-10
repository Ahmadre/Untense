import 'package:flutter/material.dart';
import 'package:untense/core/constants/app_constants.dart';

/// Represents the three therapeutic tension zones
enum TensionZone {
  /// 0–30: Patient is in mindfulness mode
  mindfulness,

  /// 30–70: Patient is in emotion regulation mode
  emotionRegulation,

  /// 70–100: Patient is in stress tolerance mode
  stressTolerance,
}

/// Extension methods for TensionZone
extension TensionZoneExtension on TensionZone {
  /// Returns the zone for a given tension value
  static TensionZone fromValue(double value) {
    if (value < AppConstants.tippingPoint1) {
      return TensionZone.mindfulness;
    } else if (value < AppConstants.tippingPoint2) {
      return TensionZone.emotionRegulation;
    } else {
      return TensionZone.stressTolerance;
    }
  }

  /// Returns the color associated with this zone
  Color get color {
    switch (this) {
      case TensionZone.mindfulness:
        return const Color(0xFF4CAF50); // Green
      case TensionZone.emotionRegulation:
        return const Color(0xFFFFA726); // Orange
      case TensionZone.stressTolerance:
        return const Color(0xFFEF5350); // Red
    }
  }

  /// Returns a lighter version of the zone color for backgrounds
  Color get lightColor {
    switch (this) {
      case TensionZone.mindfulness:
        return const Color(0xFFE8F5E9);
      case TensionZone.emotionRegulation:
        return const Color(0xFFFFF3E0);
      case TensionZone.stressTolerance:
        return const Color(0xFFFFEBEE);
    }
  }

  /// Returns the i18n key for the zone name
  String get nameKey {
    switch (this) {
      case TensionZone.mindfulness:
        return 'zones.mindfulness';
      case TensionZone.emotionRegulation:
        return 'zones.emotionRegulation';
      case TensionZone.stressTolerance:
        return 'zones.stressTolerance';
    }
  }

  /// Returns the i18n key for the zone description
  String get descriptionKey {
    switch (this) {
      case TensionZone.mindfulness:
        return 'zones.mindfulnessDesc';
      case TensionZone.emotionRegulation:
        return 'zones.emotionRegulationDesc';
      case TensionZone.stressTolerance:
        return 'zones.stressToleranceDesc';
    }
  }

  /// Returns the range as a tuple [min, max)
  (double, double) get range {
    switch (this) {
      case TensionZone.mindfulness:
        return (AppConstants.mindfulnessMin, AppConstants.mindfulnessMax);
      case TensionZone.emotionRegulation:
        return (
          AppConstants.emotionRegulationMin,
          AppConstants.emotionRegulationMax,
        );
      case TensionZone.stressTolerance:
        return (
          AppConstants.stressToleranceMin,
          AppConstants.stressToleranceMax,
        );
    }
  }
}
