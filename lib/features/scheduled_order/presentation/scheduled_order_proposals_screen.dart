import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/widgets/star_rating.dart';
import '../bloc/scheduled_order_bloc.dart';
import '../bloc/scheduled_order_event.dart';
import '../bloc/scheduled_order_state.dart';

class ScheduledOrderProposalsScreen extends StatelessWidget {
  const ScheduledOrderProposalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduledOrderBloc, ScheduledOrderState>(
      listener: (context, state) {
        if (state is ScheduledOrderConfirmed) {
          context.go('/orders/${state.order.id}', extra: state.order);
        }
      },
      builder: (context, state) {
        final proposals = state is ScheduledOrderProposalsReceived
            ? state.proposals
            : <OrderProposalModel>[];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Takliflar'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.go('/home/scheduled-order'),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.purpleLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.purple.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.purple, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${proposals.length} ta usta tayyor',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: proposals.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final proposal = proposals[index];
                    final provider = proposal.provider;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
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
                                  child: const Icon(Icons.person)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(provider.name,
                                    style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                StarRating(rating: provider.rating, size: 13),
                                const SizedBox(height: 4),
                                Text(
                                  '${(proposal.price / 1000).round()} ming so\'m · ${proposal.estimatedArrival}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ScheduledOrderBloc>()
                                .add(SelectScheduledProposal(proposal.id)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('Tanlash',
                                style: GoogleFonts.nunito(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
