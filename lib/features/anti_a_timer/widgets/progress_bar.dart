import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class CycleProgressBar extends StatelessWidget {
  final int totalSets;
  final int completedCycles;
  final bool running;

  const CycleProgressBar({
    super.key,
    required this.totalSets,
    required this.completedCycles,
    required this.running,
  });

  @override
  Widget build(BuildContext context) {
    if (!running) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSets, (i) {
        Color color;
        if (i < completedCycles) {
          color = AppColors.primary;
        } else if (i == completedCycles) {
          color = AppColors.primaryDark;
        } else {
          color = AppColors.border;
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24, height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
