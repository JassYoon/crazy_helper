import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/app_module.dart';

class MenuBarWidget extends StatelessWidget {
  final List<AppModule> modules;
  final bool showAbove;
  final VoidCallback? onModuleDoubleTap;

  const MenuBarWidget({
    super.key,
    required this.modules,
    this.showAbove = false,
    this.onModuleDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '기능을 끌어다 놓아 등록하세요',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modules.map((module) {
          return GestureDetector(
            onDoubleTap: onModuleDoubleTap,
            child: Tooltip(
              message: module.name,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: module.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  module.icon,
                  color: module.iconColor,
                  size: 20,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
