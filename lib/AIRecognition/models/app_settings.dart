class AppSettings {
  double speechRate;
  String voiceTone; // 'serious', 'clear', 'fast'
  double obstacleSensitivity;
  String sensitivityLevel; // 'low', 'medium', 'high'
  bool miniModelEnabled;
  String familiarConnectionId;
  String familiarConnectionName;

  AppSettings({
    this.speechRate = 0.43,
    this.voiceTone = 'clear',
    this.obstacleSensitivity = 0.43,
    this.sensitivityLevel = 'medium',
    this.miniModelEnabled = true,
    this.familiarConnectionId = '#VG5422200',
    this.familiarConnectionName = 'Arian Rodriguez',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      speechRate: (json['speechRate'] ?? 0.43).toDouble(),
      voiceTone: json['voiceTone'] ?? 'clear',
      obstacleSensitivity: (json['obstacleSensitivity'] ?? 0.43).toDouble(),
      sensitivityLevel: json['sensitivityLevel'] ?? 'medium',
      miniModelEnabled: json['miniModelEnabled'] ?? true,
      familiarConnectionId: json['familiarConnectionId'] ?? '',
      familiarConnectionName: json['familiarConnectionName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speechRate': speechRate,
      'voiceTone': voiceTone,
      'obstacleSensitivity': obstacleSensitivity,
      'sensitivityLevel': sensitivityLevel,
      'miniModelEnabled': miniModelEnabled,
      'familiarConnectionId': familiarConnectionId,
      'familiarConnectionName': familiarConnectionName,
    };
  }

  AppSettings copyWith({
    double? speechRate,
    String? voiceTone,
    double? obstacleSensitivity,
    String? sensitivityLevel,
    bool? miniModelEnabled,
    String? familiarConnectionId,
    String? familiarConnectionName,
  }) {
    return AppSettings(
      speechRate: speechRate ?? this.speechRate,
      voiceTone: voiceTone ?? this.voiceTone,
      obstacleSensitivity: obstacleSensitivity ?? this.obstacleSensitivity,
      sensitivityLevel: sensitivityLevel ?? this.sensitivityLevel,
      miniModelEnabled: miniModelEnabled ?? this.miniModelEnabled,
      familiarConnectionId: familiarConnectionId ?? this.familiarConnectionId,
      familiarConnectionName:
          familiarConnectionName ?? this.familiarConnectionName,
    );
  }
}
