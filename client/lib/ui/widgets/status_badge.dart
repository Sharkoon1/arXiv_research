import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final bool isRead;

  const StatusBadge({super.key, required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isRead ? AppColors.readBadge : AppColors.newBadge.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: isRead
            ? null
            : Border.all(color: AppColors.newBadge.withOpacity(0.4), width: 1),
      ),
      child: Text(
        isRead ? 'READ' : 'NEW',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isRead ? AppColors.textMuted : AppColors.primaryLight,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
