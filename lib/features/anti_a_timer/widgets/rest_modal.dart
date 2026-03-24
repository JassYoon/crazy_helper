import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class RestModal extends StatelessWidget {
  final int restAfter;
  final VoidCallback onDismiss;

  const RestModal({
    super.key,
    required this.restAfter,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 448),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.wb_sunny_outlined, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 20),
              Text('잠시 휴식을 권해드려요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                  children: [
                    const TextSpan(text: '타이머를 '),
                    TextSpan(text: '$restAfter번',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const TextSpan(text: ' 사용하셨어요.\n5~10분 정도 몸을 이완시키고 돌아오세요.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('충분히 쉬었어요'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
