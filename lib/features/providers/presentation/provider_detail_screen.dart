import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/star_rating.dart';
import '../../posts/bloc/posts_bloc.dart';
import '../../posts/presentation/provider_posts_tab.dart';

class ProviderDetailScreen extends StatefulWidget {
  final ProviderModel provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen>
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostsBloc(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: _buildInfoCard(context),
            ),
            SliverToBoxAdapter(
              child: _buildStatsRow(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelStyle: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle:
                      GoogleFonts.nunito(fontSize: 14),
                  tabs: const [
                    Tab(text: 'Ma\'lumot'),
                    Tab(text: 'Ishlar'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(context),
              ProviderPostsTab(providerId: widget.provider.id),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textPrimary, size: 18),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.share_rounded,
                  color: AppColors.textPrimary, size: 18),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: widget.provider.portfolio.isNotEmpty
              ? widget.provider.portfolio.first
              : 'https://picsum.photos/seed/${widget.provider.id}/800/600',
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: AppColors.grey200),
          errorWidget: (_, _, _) => Container(color: AppColors.grey200),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final provider = widget.provider;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
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
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.grey200),
                    errorWidget: (_, _, _) => Container(
                        color: AppColors.grey200,
                        child: const Icon(Icons.person, size: 36)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.name,
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (provider.isVerified)
                            const Icon(Icons.verified_rounded,
                                size: 20, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          provider.categoryName,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: provider.isOnline
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.grey200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: provider.isOnline
                              ? AppColors.success
                              : AppColors.grey500,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: provider.isOnline
                              ? AppColors.success
                              : AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            _iconRow(Icons.star_rounded, AppColors.yellow,
                '${provider.rating} reyting · ${provider.reviewCount} sharh'),
            const SizedBox(height: 8),
            _iconRow(Icons.location_on_outlined, AppColors.textSecondary,
                provider.location),
            const SizedBox(height: 8),
            _iconRow(Icons.access_time_rounded, AppColors.textSecondary,
                provider.workingHours),
            if (provider.hasTransport) ...[
              const SizedBox(height: 8),
              _iconRow(Icons.directions_car_rounded, AppColors.teal,
                  'Transport mavjud'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final provider = widget.provider;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '${provider.completedOrders}',
              label: 'Buyurtma',
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              value: '${provider.rating}',
              label: 'Reyting',
              icon: Icons.star_rounded,
              color: AppColors.yellow,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: _StatCard(
              value: '98%',
              label: 'Javob',
              icon: Icons.reply_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
    final provider = widget.provider;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceTypes(provider),
          const SizedBox(height: 16),
          _buildPriceSection(provider),
          const SizedBox(height: 16),
          _buildPortfolio(provider),
          const SizedBox(height: 16),
          _buildReviews(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildServiceTypes(ProviderModel provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Xizmat turlari',
          style: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          provider.bio,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(ProviderModel provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Narx',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                provider.priceRange,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolio(ProviderModel provider) {
    if (provider.portfolio.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Portfolio',
          style: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: provider.portfolio.length,
            separatorBuilder: (_, i) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: provider.portfolio[index],
                  width: 160,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(color: AppColors.grey200),
                  errorWidget: (_, _, _) =>
                      Container(color: AppColors.grey200),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    final reviews = [
      (
        'Akbar T.',
        'https://i.pravatar.cc/50?img=30',
        4.8,
        'Juda yaxshi usta, vaqtida keldi va sifatli ish qildi.'
      ),
      (
        'Malika S.',
        'https://i.pravatar.cc/50?img=31',
        5.0,
        'Ajoyib! Tavsiya etaman, professional.'
      ),
      (
        'Sarvar N.',
        'https://i.pravatar.cc/50?img=32',
        4.5,
        'Narxi munosib, ishining sifati yaxshi.'
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sharhlar',
          style: GoogleFonts.nunito(
              fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        ...reviews.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: r.$2,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: AppColors.grey200),
                        errorWidget: (_, _, _) => Container(
                            color: AppColors.grey200,
                            child: const Icon(Icons.person, size: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r.$1,
                                  style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              StarRating(rating: r.$3, size: 12),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            r.$4,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final provider = widget.provider;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              label: 'Chat',
              variant: ButtonVariant.outline,
              prefixIcon: Icons.chat_bubble_outline_rounded,
              onPressed: () =>
                  context.push('/chat/${provider.id}', extra: provider),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomButton(
              label: 'Buyurtma berish',
              prefixIcon: Icons.bolt_rounded,
              onPressed: () => context.push('/home/quick-order'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
