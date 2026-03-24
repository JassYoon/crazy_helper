import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating; // 0-3
  final ValueChanged<int> onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () {
            // Click on filled star at same position → unfill from there
            if (filled && i == rating - 1) {
              onChanged(i);
            } else {
              onChanged(i + 1);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: filled
                  ? const Color(0xFFFFB74D)
                  : const Color(0xFF475569),
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
