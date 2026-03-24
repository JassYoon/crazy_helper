import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/app_module.dart';
import '../widgets/logo_widget.dart';
import '../features/anti_a_timer/screens/timer_screen.dart';
import '../features/todolist/screens/todo_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(String moduleId)? onModuleDragToMenu;
  final VoidCallback? onSwitchToWidget;

  const HomeScreen({
    super.key,
    this.onModuleDragToMenu,
    this.onSwitchToWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logo + Title
            Column(
              children: [
                const LogoWidget(size: 72),
                const SizedBox(height: 12),
                Text(
                  '제정신 지킴이',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '마음의 평화를 지켜드립니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Module list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  itemCount: allModules.length,
                  itemBuilder: (context, index) {
                    return _ModuleCard(
                      module: allModules[index],
                      onDragToMenu: onModuleDragToMenu,
                    );
                  },
                ),
              ),
            ),
            // Menu bar drop zone + minimize to widget button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: DragTarget<String>(
                      onAcceptWithDetails: (details) {
                        onModuleDragToMenu?.call(details.data);
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHovering = candidateData.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 48,
                          decoration: BoxDecoration(
                            color: isHovering
                                ? AppColors.primaryLight.withValues(alpha: 0.5)
                                : AppColors.primaryVeryLight,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isHovering
                                  ? AppColors.primary
                                  : AppColors.primaryLight,
                              width: isHovering ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: isHovering
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isHovering ? '놓아서 메뉴에 추가' : '여기에 끌어다 놓기',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isHovering
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: isHovering
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Minimize to widget
                  GestureDetector(
                    onTap: onSwitchToWidget,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryVeryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryLight),
                      ),
                      child: Icon(
                        Icons.minimize,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final AppModule module;
  final Function(String moduleId)? onDragToMenu;

  const _ModuleCard({required this.module, this.onDragToMenu});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final card = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onDoubleTap: widget.module.available
            ? () {
                Widget? screen;
                if (widget.module.id == 'anti_a_timer') {
                  screen = const TimerScreen();
                } else if (widget.module.id == 'todolist') {
                  screen = const TodoScreen();
                }
                if (screen != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => screen!),
                  );
                }
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _hovering
                ? AppColors.cardHover
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              // Circular icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.module.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.module.icon,
                  color: widget.module.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Module name
              Expanded(
                child: Text(
                  widget.module.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: widget.module.available
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              if (!widget.module.available)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryVeryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '준비 중',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Draggable for adding to menu bar
    return Draggable<String>(
      data: widget.module.id,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.module.icon,
                  color: widget.module.iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.module.name,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    );
  }
}
