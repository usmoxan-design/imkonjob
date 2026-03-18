import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/order_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/star_rating.dart';
import '../bloc/tender_order_bloc.dart';
import '../bloc/tender_order_event.dart';
import '../bloc/tender_order_state.dart';

class TenderOrderProposalsScreen extends StatelessWidget {
  final List<OrderProposalModel> proposals;

  const TenderOrderProposalsScreen({super.key, required this.proposals});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TenderOrderBloc, TenderOrderState>(
      listener: (context, state) {
        if (state is TenderOrderConfirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usta tanlandi! Tez orada bog\'lanadi.',
                  style: GoogleFonts.nunito(color: Colors.white)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Takliflar (${proposals.length})',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: proposals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.hourglass_empty_rounded,
                        size: 56, color: AppColors.grey400),
                    const SizedBox(height: 12),
                    Text('Hali takliflar kelmadi',
                        style: GoogleFonts.nunito(
                            fontSize: 16, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Bir oz kuting...',
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: proposals.length,
                separatorBuilder: (_, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _ProposalCard(
                  proposal: proposals[index],
                  onSelect: () => context
                      .read<TenderOrderBloc>()
                      .add(SelectTenderProposal(proposals[index].id)),
                ),
              ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final OrderProposalModel proposal;
  final VoidCallback onSelect;

  const _ProposalCard({required this.proposal, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final provider = proposal.provider;
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
          Row(
            children: [
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: provider.avatar,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: AppColors.grey200),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.grey200,
                    child: const Icon(Icons.person, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(provider.name,
                            style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded,
                              size: 14, color: AppColors.primary),
                        ],
                      ],
                    ),
                    StarRating(
                        rating: provider.rating,
                        size: 13,
                        showLabel: true),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(proposal.price / 1000).round()} 000',
                    style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                  Text("so'm",
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          if (proposal.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                proposal.note,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.teal),
              const SizedBox(width: 4),
              Text(proposal.estimatedArrival,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              SizedBox(
                width: 140,
                child: BlocBuilder<TenderOrderBloc, TenderOrderState>(
                  builder: (context, state) => CustomButton(
                    label: 'Tanlash',
                    prefixIcon: Icons.check_rounded,
                    isLoading: state is TenderOrderConfirmed,
                    onPressed: onSelect,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
