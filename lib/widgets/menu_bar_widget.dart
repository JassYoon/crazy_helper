import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/app_module.dart';
import 'module_icon_widget.dart';

class MenuBarWidget extends StatelessWidget {
  final List<AppModule> modules;
  final bool showAbove;
  /// 메뉴에 등록된 `module.id`로 기능 화면을 열 때.
  final ValueChanged<String>? onModuleOpen;

  const MenuBarWidget({
    super.key,
    required this.modules,
    this.showAbove = false,
    this.onModuleOpen,
  });

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppFloatingChrome.menuPanel,
        child: Text(
          '기능을 끌어다 놓아 등록하세요',
          style: appStyle(
            context,
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: AppFloatingChrome.menuPanel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modules.map((module) {
          return GestureDetector(
            onTap: onModuleOpen == null ? null : () => onModuleOpen!(module.id),
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
                child: ModuleIconWidget(
                  module: module,
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
