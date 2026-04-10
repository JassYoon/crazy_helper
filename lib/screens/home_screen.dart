import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/module_registry.dart';
import '../models/app_module.dart';
import '../widgets/logo_widget.dart';
import '../widgets/module_icon_widget.dart';
import '../features/anti_a_timer/screens/timer_screen.dart';
import '../features/todolist/screens/todo_screen.dart';
import '../features/donelist/screens/done_screen.dart';

class HomeScreen extends StatelessWidget {
  final ModuleRegistry registry;
  final VoidCallback? onSwitchToWidget;

  const HomeScreen({
    super.key,
    required this.registry,
    this.onSwitchToWidget,
  });

  void _openModule(BuildContext context, String moduleId) {
    final screen = switch (moduleId) {
      'anti_a_timer' => const TimerScreen(),
      'todolist' => const TodoScreen(),
      'donelist' => const DoneScreen(),
      _ => null,
    };
    if (screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

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
                  style: appStyle(
                    context,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '건강한 생활에 건강한 정신이 깃든다',
                  style: appStyle(
                    context,
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Bento box module grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: allModules.length,
                  itemBuilder: (context, index) {
                    return _BentoCard(
                      module: allModules[index],
                      onTap: () => _openModule(context, allModules[index].id),
                    );
                  },
                ),
              ),
            ),
            // Bottom toolbar: 위젯 메뉴 관리 + 위젯 모드 전환
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  // 위젯 메뉴 관리 버튼
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showWidgetMenuDialog(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryVeryLight,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.primaryLight),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.widgets_outlined, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '위젯 메뉴 관리',
                                style: appStyle(
                                  context,
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 위젯 모드 전환
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

  void _showWidgetMenuDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: registry,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '위젯 메뉴 관리',
                    style: appStyle(context,
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '위젯 클릭 시 표시될 기능을 선택하세요',
                    style: appStyle(context, fontSize: 12, color: AppColors.textHint),
                  ),
                  const SizedBox(height: 16),
                  ...allModules.map((module) {
                    final inMenu = registry.isInMenu(module.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          if (inMenu) {
                            registry.removeFromMenu(module.id);
                          } else {
                            registry.addToMenu(module.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: inMenu ? AppColors.primaryVeryLight : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: inMenu ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: module.iconColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: ModuleIconWidget(module: module, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  module.name,
                                  style: appStyle(context,
                                      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                ),
                              ),
                              Icon(
                                inMenu ? Icons.check_circle : Icons.circle_outlined,
                                color: inMenu ? AppColors.primary : AppColors.textHint,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BentoCard extends StatefulWidget {
  final AppModule module;
  final VoidCallback onTap;

  const _BentoCard({required this.module, required this.onTap});

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.cardHover : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovering ? AppColors.primaryLight : AppColors.border,
            ),
            boxShadow: _hovering
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.module.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: ModuleIconWidget(
                  module: widget.module,
                  size: 26,
                ),
              ),
              const Spacer(flex: 2),
              Text(
                widget.module.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: appStyle(
                  context,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
