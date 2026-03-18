import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../bloc/company_mode_bloc.dart';
import '../bloc/company_mode_event.dart';
import '../bloc/company_mode_state.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CompanyModeBloc>().add(const LoadCompanyDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CompanyModeBloc, CompanyModeState>(
        builder: (context, state) {
          if (state is CompanyDashboardLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                context
                    .read<CompanyModeBloc>()
                    .add(const LoadCompanyDashboard());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(state)),
                  SliverToBoxAdapter(child: _buildStats(state)),
                  SliverToBoxAdapter(
                      child: _buildLeadsSection(context, state)),
                  SliverToBoxAdapter(
                      child: _buildActiveOrders(context, state)),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHeader(CompanyDashboardLoaded state) {
    final company = state.company;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(company.logo),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          company.name,
                          style: GoogleFonts.nunito(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (company.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              size: 16, color: Colors.white),
                        ],
                      ],
                    ),
                    Text(
                      '${company.rating} ⭐  •  ${company.reviewCount} sharh',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(CompanyDashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _StatChip(
            label: 'Faol buyurtma',
            value: '${state.activeOrders.length}',
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Yangi lead',
            value: '${state.leads.length}',
            color: AppColors.orange,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Reyting',
            value: '${state.company.rating}',
            color: AppColors.yellow,
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsSection(
      BuildContext context, CompanyDashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yangi leadlar',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (state.leads.isEmpty)
            _emptyState(
                'Hozircha yangi leadlar yo\'q', Icons.inbox_outlined)
          else
            ...state.leads.map((order) => _LeadCard(
                  order: order,
                  onAccept: () => context
                      .read<CompanyModeBloc>()
                      .add(AcceptLead(order.id)),
                  onReject: () => context
                      .read<CompanyModeBloc>()
                      .add(RejectLead(order.id)),
                )),
        ],
      ),
    );
  }

  Widget _buildActiveOrders(
      BuildContext context, CompanyDashboardLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Faol buyurtmalar',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (state.activeOrders.isEmpty)
            _emptyState('Faol buyurtmalar yo\'q',
                Icons.assignment_outlined)
          else
            ...state.activeOrders.map((order) => _OrderRow(order: order)),
        ],
      ),
    );
  }

  Widget _emptyState(String text, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.grey400),
          const SizedBox(height: 8),
          Text(text,
              style: GoogleFonts.nunito(
                  fontSize: 14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _LeadCard(
      {required this.order,
      required this.onAccept,
      required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(order.serviceType,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange)),
              ),
              const Spacer(),
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              Text(
                order.address.length > 25
                    ? '${order.address.substring(0, 25)}...'
                    : order.address,
                style: GoogleFonts.nunito(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.description,
            style: GoogleFonts.nunito(
                fontSize: 13, color: AppColors.textPrimary, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Rad etish',
                  variant: ButtonVariant.outline,
                  onPressed: onReject,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  label: 'Qabul qilish',
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final OrderModel order;

  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.handyman_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.serviceType,
                    style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                Text(
                  order.address.length > 30
                      ? '${order.address.substring(0, 30)}...'
                      : order.address,
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusBadge(status: order.status),
        ],
      ),
    );
  }
}
