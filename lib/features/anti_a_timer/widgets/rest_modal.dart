import 'package:flutter/material.dart';

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
      color: const Color(0xFF020617).withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 448),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sun icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFF34D399),
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                '잠시 휴식을 권해드려요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(text: '타이머를 '),
                    TextSpan(
                      text: '$restAfter번',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const TextSpan(text: ' 사용하셨어요.\n'),
                    const TextSpan(text: '5~10분 정도 몸을 이완시키고 돌아오세요.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
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
