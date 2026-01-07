class AppSettings {
  final double confidenceThreshold;
  final bool autoContinuousScan;
  final bool soundEnabled;
  final bool vibrationEnabled;

  AppSettings({
    this.confidenceThreshold = 0.8,
    this.autoContinuousScan = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  // Default settings
  factory AppSettings.defaults() {
    return AppSettings(
      confidenceThreshold: 0.8,
      autoContinuousScan: true,
      soundEnabled: true,
      vibrationEnabled: true,
    );
  }

  // Copy with
  AppSettings copyWith({
    double? confidenceThreshold,
    bool? autoContinuousScan,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return AppSettings(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      autoContinuousScan: autoContinuousScan ?? this.autoContinuousScan,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  // From JSON (for SharedPreferences)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      confidenceThreshold: (json['confidence_threshold'] as num?)?.toDouble() ?? 0.8,
      autoContinuousScan: json['auto_continuous_scan'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
    );
  }

  // To JSON (for SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'confidence_threshold': confidenceThreshold,
      'auto_continuous_scan': autoContinuousScan,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
    };
  }

  // Get confidence threshold as percentage
  int get confidenceThresholdPercent => (confidenceThreshold * 100).toInt();

  @override
  String toString() {
    return 'AppSettings(confidenceThreshold: $confidenceThreshold, autoContinuousScan: $autoContinuousScan, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.confidenceThreshold == confidenceThreshold &&
        other.autoContinuousScan == autoContinuousScan &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      confidenceThreshold,
      autoContinuousScan,
      soundEnabled,
      vibrationEnabled,
    );
  }
}
