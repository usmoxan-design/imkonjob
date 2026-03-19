import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/order_model.dart';
import '../../../core/widgets/status_badge.dart';

class ProviderOrdersScreen extends StatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showUpdateStatus(BuildContext context, OrderModel order) {
    final statuses = [
      (OrderStatus.onTheWay, 'Yo\'lda'),
      (OrderStatus.arrived, 'Yetib keldim'),
      (OrderStatus.inProgress, 'Ishni boshladim'),
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Holatni yangilang',
                style: AppTextStyles.heading3()),
            const SizedBox(height: 16),
            ...statuses.map((s) => ListTile(
                  leading: Icon(Icons.circle,
                      size: 10, color: AppColors.primary),
                  title: Text(s.$2,
                      style: GoogleFonts.nunito(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Holat yangilandi: ${s.$2}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Buyurtmani tugatish',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text('Buyurtmani tugatganingizni tasdiqlaysizmi?',
            style: GoogleFonts.nunito(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Bekor qilish',
                style: GoogleFonts.nunito(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Buyurtma muvaffaqiyatli tugatildi!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success, elevation: 0),
            child: Text('Tugatish',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeStatuses = {
      OrderStatus.providerSelected,
      OrderStatus.onTheWay,
      OrderStatus.arrived,
      OrderStatus.inProgress,
    };
    final allOrders = MockData.orders;
    final active =
        allOrders.where((o) => activeStatuses.contains(o.status)).toList();
    final past = allOrders
        .where((o) =>
            o.status == OrderStatus.completed ||
            o.status == OrderStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Buyurtmalar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Faol'),
            Tab(text: 'Tugallangan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(active, isActive: true),
          _buildList(past, isActive: false),
        ],
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.assignment_outlined,
                size: 64, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'Faol buyurtmalar yo\'q'
                  : 'Tugallangan buyurtmalar yo\'q',
              style: AppTextStyles.heading3(color: context.txtSecondary),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surf,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderClr),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.serviceType,
                      style: AppTextStyles.cardTitle(),
                    ),
                  ),
                  StatusBadge(status: order.status, isSmall: true),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: context.txtSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.address,
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: context.txtSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time_outlined,
                      size: 14, color: context.txtSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM, HH:mm').format(order.createdAt),
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: context.txtSecondary),
                  ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showUpdateStatus(context, order),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Yangilash',
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _showCompleteDialog(context, order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Tugatish',
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
