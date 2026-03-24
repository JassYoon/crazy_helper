import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRating({super.key, required this.rating, required this.onChanged, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () {
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
              color: filled ? AppColors.star : AppColors.textHint,
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
