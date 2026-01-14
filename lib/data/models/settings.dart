class AppSettings {
  final double confidenceThreshold;
  final bool autoContinuousScan;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int startupDelayMs;
  final int confirmationFrames;

  AppSettings({
    this.confidenceThreshold = 0.8,
    this.autoContinuousScan = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.startupDelayMs = 800,
    this.confirmationFrames = 3,
  });

  // Default settings
  factory AppSettings.defaults() {
    return AppSettings(
      confidenceThreshold: 0.8,
      autoContinuousScan: true,
      soundEnabled: true,
      vibrationEnabled: true,
      startupDelayMs: 800,
      confirmationFrames: 3,
    );
  }

  // Copy with
  AppSettings copyWith({
    double? confidenceThreshold,
    bool? autoContinuousScan,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? startupDelayMs,
    int? confirmationFrames,
  }) {
    return AppSettings(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      autoContinuousScan: autoContinuousScan ?? this.autoContinuousScan,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      startupDelayMs: startupDelayMs ?? this.startupDelayMs,
      confirmationFrames: confirmationFrames ?? this.confirmationFrames,
    );
  }

  // From JSON (for SharedPreferences)
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      confidenceThreshold: (json['confidence_threshold'] as num?)?.toDouble() ?? 0.8,
      autoContinuousScan: json['auto_continuous_scan'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
      startupDelayMs: json['startup_delay_ms'] as int? ?? 800,
      confirmationFrames: json['confirmation_frames'] as int? ?? 3,
    );
  }

  // To JSON (for SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'confidence_threshold': confidenceThreshold,
      'auto_continuous_scan': autoContinuousScan,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'startup_delay_ms': startupDelayMs,
      'confirmation_frames': confirmationFrames,
    };
  }

  // Get confidence threshold as percentage
  int get confidenceThresholdPercent => (confidenceThreshold * 100).toInt();

  // Get startup delay in seconds for display
  double get startupDelaySeconds => startupDelayMs / 1000.0;

  @override
  String toString() {
    return 'AppSettings(confidenceThreshold: $confidenceThreshold, autoContinuousScan: $autoContinuousScan, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, startupDelayMs: $startupDelayMs, confirmationFrames: $confirmationFrames)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.confidenceThreshold == confidenceThreshold &&
        other.autoContinuousScan == autoContinuousScan &&
        other.soundEnabled == soundEnabled &&
        other.vibrationEnabled == vibrationEnabled &&
        other.startupDelayMs == startupDelayMs &&
        other.confirmationFrames == confirmationFrames;
  }

  @override
  int get hashCode {
    return Object.hash(
      confidenceThreshold,
      autoContinuousScan,
      soundEnabled,
      vibrationEnabled,
      startupDelayMs,
      confirmationFrames,
    );
  }
}
