import 'package:flutter/material.dart';

class AppModule {
  final String id;
  final String name;
  final IconData icon;
  final Color iconColor;

  const AppModule({
    required this.id,
    required this.name,
    required this.icon,
    this.iconColor = const Color(0xFF8BC34A),
  });
}

const List<AppModule> allModules = [
  AppModule(
    id: 'anti_a_timer',
    name: '심호흡 타이머',
    icon: Icons.schedule,
    iconColor: Color(0xFF66BB6A),
  ),
  AppModule(
    id: 'todolist',
    name: '할 일',
    icon: Icons.checklist,
    iconColor: Color(0xFF42A5F5),
  ),
];
