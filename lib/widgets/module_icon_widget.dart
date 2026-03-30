import 'package:flutter/material.dart';
import '../models/app_module.dart';
import '../features/todolist/widgets/todo_list_shortcut_icon.dart';

class ModuleIconWidget extends StatelessWidget {
  final AppModule module;
  final double size;

  const ModuleIconWidget({
    super.key,
    required this.module,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (module.id == 'todolist') {
      return TodoListShortcutIcon(color: module.iconColor, size: size);
    }
    return Icon(module.icon, color: module.iconColor, size: size);
  }
}
