import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showLabel;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 14,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (starValue <= rating) {
            return Icon(Icons.star_rounded, size: size, color: AppColors.yellow);
          } else if (starValue - 0.5 <= rating) {
            return Icon(Icons.star_half_rounded, size: size, color: AppColors.yellow);
          } else {
            return Icon(Icons.star_outline_rounded, size: size, color: AppColors.grey300);
          }
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size - 2,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
