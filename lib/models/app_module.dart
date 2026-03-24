import 'package:flutter/material.dart';

class AppModule {
  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;
  final bool available;

  const AppModule({
    required this.id,
    required this.name,
    required this.icon,
    this.iconColor = const Color(0xFF8BC34A),
    this.available = true,
  });
}

const List<AppModule> allModules = [
  AppModule(
    id: 'anti_a_timer',
    name: '마음 안정 타이머',
    icon: Icons.self_improvement,
    iconColor: Color(0xFF66BB6A),
  ),
  AppModule(
    id: 'todolist',
    name: '할 일',
    icon: Icons.checklist,
    iconColor: Color(0xFF42A5F5),
  ),
  AppModule(
    id: 'white_noise',
    name: '백색 소음',
    icon: Icons.graphic_eq,
    iconColor: Color(0xFF78909C),
    available: false,
  ),
  AppModule(
    id: 'mood_journal',
    name: '감정 일기',
    icon: Icons.edit_note,
    iconColor: Color(0xFFFFB74D),
    available: false,
  ),
  AppModule(
    id: 'stretch_guide',
    name: '스트레칭 가이드',
    icon: Icons.accessibility_new,
    iconColor: Color(0xFFEF5350),
    available: false,
  ),
  AppModule(
    id: 'focus_timer',
    name: '집중 타이머',
    icon: Icons.timer,
    iconColor: Color(0xFFAB47BC),
    available: false,
  ),
  AppModule(
    id: 'affirmation',
    name: '긍정 확언',
    icon: Icons.favorite,
    iconColor: Color(0xFFEC407A),
    available: false,
  ),
];
