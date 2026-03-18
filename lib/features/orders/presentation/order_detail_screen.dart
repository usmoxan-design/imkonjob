import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Buyurtma #${order.id.substring(0, 8).toUpperCase()}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildTimeline(),
            const SizedBox(height: 16),
            if (order.provider != null) _buildProviderCard(context),
            if (order.provider != null) const SizedBox(height: 16),
            _buildOrderDetails(),
            const SizedBox(height: 16),
            if (order.estimatedPrice != null) _buildPriceCard(),
            const SizedBox(height: 16),
            _buildActions(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.handyman_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.serviceType,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMMM yyyy, HH:mm').format(order.createdAt),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: order.status),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final steps = [
      (OrderStatus.searching, 'Qidirilmoqda', Icons.search_rounded),
      (OrderStatus.providerSelected, 'Usta tanlandi', Icons.person_rounded),
      (OrderStatus.onTheWay, 'Usta yo\'lda', Icons.directions_car_rounded),
      (OrderStatus.inProgress, 'Bajarilyapti', Icons.build_rounded),
      (OrderStatus.completed, 'Tugallandi', Icons.check_circle_rounded),
    ];

    final currentIndex =
        steps.indexWhere((s) => s.$1 == order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Holat',
            style: GoogleFonts.nunito(
                fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isDone = currentIndex >= index;
            final isCurrent = currentIndex == index;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.primary : AppColors.grey200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDone ? Icons.check_rounded : step.$3,
                        size: 15,
                        color: isDone ? Colors.white : AppColors.grey400,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 28,
                        color: isDone ? AppColors.primary : AppColors.grey200,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    step.$2,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isDone
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Hozir',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context) {
    final provider = order.provider!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Usta',
            style: GoogleFonts.nunito(
                fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: provider.avatar,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  placeholder: (_, u) =>
                      Container(color: AppColors.grey200),
                  errorWidget: (_, u, e) => Container(
                      color: AppColors.grey200,
                      child: const Icon(Icons.person, size: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.name,
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(provider.categoryName,
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (order.estimatedArrival != null)
                Column(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        color: AppColors.teal, size: 18),
                    Text(
                      order.estimatedArrival!,
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: AppColors.teal,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buyurtma tafsilotlari',
              style: GoogleFonts.nunito(
                  fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _detailRow('Xizmat turi', order.serviceType),
          _detailRow('Tavsif', order.description),
          _detailRow('Manzil', order.address),
          _detailRow(
              'Sana', DateFormat('dd MMM yyyy').format(order.createdAt)),
          _detailRow(
              'Tur',
              order.type == OrderType.quick
                  ? 'Tezkor'
                  : 'Rejalashtirilgan'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Jami narx',
              style: GoogleFonts.nunito(
                  fontSize: 15, fontWeight: FontWeight.w700)),
          Text(
            '${(order.estimatedPrice! / 1000).round()} 000 so\'m',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        if (order.provider != null)
          CustomButton(
            label: 'Usta bilan chat',
            variant: ButtonVariant.outline,
            prefixIcon: Icons.chat_bubble_outline_rounded,
            onPressed: () => context.push(
              '/chat/${order.provider!.id}',
              extra: order.provider,
            ),
          ),
        if (order.status == OrderStatus.completed) ...[
          const SizedBox(height: 12),
          CustomButton(
            label: 'Baholash',
            prefixIcon: Icons.star_rounded,
            onPressed: () {},
          ),
        ],
        const SizedBox(height: 12),
        CustomButton(
          label: 'Muammo xabarlash',
          variant: ButtonVariant.text,
          prefixIcon: Icons.flag_outlined,
          onPressed: () {},
        ),
      ],
    );
  }
}
