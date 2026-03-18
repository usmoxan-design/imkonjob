import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/order_model.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: GoogleFonts.nunito(
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig() {
    switch (status) {
      case OrderStatus.searching:
        return _StatusConfig(
          label: 'Qidirilmoqda',
          bgColor: const Color(0xFFFFF7ED),
          textColor: const Color(0xFFC2410C),
          dotColor: const Color(0xFFF97316),
        );
      case OrderStatus.proposalsReceived:
        return _StatusConfig(
          label: 'Takliflar keldi',
          bgColor: const Color(0xFFEFF6FF),
          textColor: AppColors.primary,
          dotColor: AppColors.primary,
        );
      case OrderStatus.providerSelected:
        return _StatusConfig(
          label: 'Usta tanlandi',
          bgColor: const Color(0xFFF5F3FF),
          textColor: const Color(0xFF6D28D9),
          dotColor: const Color(0xFF7C3AED),
        );
      case OrderStatus.onTheWay:
        return _StatusConfig(
          label: 'Yo\'lda',
          bgColor: const Color(0xFFF0FDFA),
          textColor: AppColors.teal,
          dotColor: AppColors.teal,
        );
      case OrderStatus.arrived:
        return _StatusConfig(
          label: 'Yetib keldi',
          bgColor: const Color(0xFFECFDF5),
          textColor: const Color(0xFF059669),
          dotColor: AppColors.success,
        );
      case OrderStatus.inProgress:
        return _StatusConfig(
          label: 'Bajarilyapti',
          bgColor: const Color(0xFFEFF6FF),
          textColor: AppColors.primary,
          dotColor: AppColors.primary,
        );
      case OrderStatus.completed:
        return _StatusConfig(
          label: 'Tugallandi',
          bgColor: const Color(0xFFECFDF5),
          textColor: const Color(0xFF059669),
          dotColor: AppColors.success,
        );
      case OrderStatus.cancelled:
        return _StatusConfig(
          label: 'Bekor qilindi',
          bgColor: const Color(0xFFFEF2F2),
          textColor: AppColors.error,
          dotColor: AppColors.error,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color dotColor;

  _StatusConfig({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.dotColor,
  });
}
