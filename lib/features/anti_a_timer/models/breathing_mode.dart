import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BreathingPhase {
  final String label;
  final Color color;
  final int seconds;

  const BreathingPhase({
    required this.label,
    required this.color,
    required this.seconds,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'color': color.toARGB32(),
        'seconds': seconds,
      };

  factory BreathingPhase.fromJson(Map<String, dynamic> json) {
    return BreathingPhase(
      label: json['label'] as String,
      color: Color(json['color'] as int),
      seconds: json['seconds'] as int,
    );
  }
}

class BreathingMode {
  final String id;
  final String name;
  final String description;
  final List<BreathingPhase> phases;
  final bool isBuiltIn;

  const BreathingMode({
    required this.id,
    required this.name,
    required this.description,
    required this.phases,
    this.isBuiltIn = false,
  });

  int get totalPerCycle =>
      phases.fold(0, (sum, phase) => sum + phase.seconds);

  int totalDuration(int sets) => sets * totalPerCycle;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'phases': phases.map((p) => p.toJson()).toList(),
      };

  factory BreathingMode.fromJson(Map<String, dynamic> json) {
    return BreathingMode(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      phases: (json['phases'] as List)
          .map((p) => BreathingPhase.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

const kInhaleColor = Color(0xFF60A5FA);
const kHoldColor = Color(0xFFA78BFA);
const kExhaleColor = Color(0xFF34D399);

const kPhaseTemplates = [
  BreathingPhase(label: '들이쉬기', color: kInhaleColor, seconds: 4),
  BreathingPhase(label: '참기', color: kHoldColor, seconds: 4),
  BreathingPhase(label: '내쉬기', color: kExhaleColor, seconds: 4),
];

final boxBreathing = BreathingMode(
  id: '444',
  name: '4-4-4',
  description: '박스 호흡',
  isBuiltIn: true,
  phases: const [
    BreathingPhase(label: '들이쉬기', color: kInhaleColor, seconds: 4),
    BreathingPhase(label: '참기', color: kHoldColor, seconds: 4),
    BreathingPhase(label: '내쉬기', color: kExhaleColor, seconds: 4),
  ],
);

final anxietyRelief = BreathingMode(
  id: '478',
  name: '4-7-8',
  description: '불안 해소',
  isBuiltIn: true,
  phases: const [
    BreathingPhase(label: '들이쉬기', color: kInhaleColor, seconds: 4),
    BreathingPhase(label: '참기', color: kHoldColor, seconds: 7),
    BreathingPhase(label: '내쉬기', color: kExhaleColor, seconds: 8),
  ],
);

class BreathingModeStore {
  static const _key = 'customBreathingModes';

  static Future<List<BreathingMode>> loadAll() async {
    final customs = await _loadCustom();
    return [boxBreathing, anxietyRelief, ...customs];
  }

  static Future<List<BreathingMode>> _loadCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List;
    return list
        .map((e) => BreathingMode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveCustom(List<BreathingMode> customs) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(customs.map((m) => m.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }

  static Future<void> addCustom(BreathingMode mode) async {
    final customs = await _loadCustom();
    customs.add(mode);
    await saveCustom(customs);
  }

  static Future<void> removeCustom(String modeId) async {
    final customs = await _loadCustom();
    customs.removeWhere((m) => m.id == modeId);
    await saveCustom(customs);
  }
}
