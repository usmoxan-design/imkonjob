import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/order_model.dart';
import '../../../core/widgets/status_badge.dart';

class CompanyOrdersScreen extends StatefulWidget {
  const CompanyOrdersScreen({super.key});

  @override
  State<CompanyOrdersScreen> createState() => _CompanyOrdersScreenState();
}

class _CompanyOrdersScreenState extends State<CompanyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = MockData.orders;
    final active = all
        .where((o) =>
            o.status == OrderStatus.inProgress ||
            o.status == OrderStatus.onTheWay ||
            o.status == OrderStatus.providerSelected)
        .toList();
    final completed =
        all.where((o) => o.status == OrderStatus.completed).toList();
    final searching =
        all.where((o) => o.status == OrderStatus.searching).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Buyurtmalar',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: 'Faol (${active.length})'),
            Tab(text: 'Tugallangan (${completed.length})'),
            Tab(text: 'Yangi (${searching.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderList(orders: active),
          _OrderList(orders: completed),
          _OrderList(orders: searching),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<OrderModel> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 56, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text('Buyurtmalar yo\'q',
                style: GoogleFonts.nunito(
                    fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, i) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _OrderCard(order: orders[index]),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.serviceType,
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.description,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(order.address,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ),
              if (order.estimatedPrice != null)
                Text(
                  '${(order.estimatedPrice! / 1000).round()} 000 so\'m',
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
