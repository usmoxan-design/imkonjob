import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/category_model.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/provider_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../core/theme/app_text_styles.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.name.split(' ').first;
    }
    return 'Mehmon';
  }

  Future<void> _startVoiceSearch() async {
    final available = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'uz_UZ',
        onResult: (r) {
          if (r.finalResult) {
            setState(() {
              _searchController.text = r.recognizedWords;
              _isListening = false;
            });
            context
                .read<HomeBloc>()
                .add(SearchProviders(_searchController.text));
          }
        },
      );
    }
  }

  void _stopVoiceSearch() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<HomeBloc>().add(const RefreshHomeData());
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, isDark)),
            SliverToBoxAdapter(child: _buildSearchBar(context, isDark)),
            SliverToBoxAdapter(child: _buildQuickOrderHero(context)),
            SliverToBoxAdapter(child: _buildSecondaryCtaRow(context, isDark)),
            SliverToBoxAdapter(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) return _buildCategoriesShimmer();
                  if (state is HomeLoaded) return _buildCategories(context, state, isDark);
                  return const SizedBox.shrink();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) return _buildProvidersShimmer();
                  if (state is HomeLoaded) return _buildSuggestedProviders(context, state, isDark);
                  return const SizedBox.shrink();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoaded) return _buildNearbyProviders(context, state, isDark);
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final userName = _getUserName(context);
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Salom, $userName 👋',
                style: AppTextStyles.heading2(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () => _showLocationSheet(context, isDark),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text(
                      AppConstants.defaultLocation,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/operator'),
                child: Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.tealLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.headset_mic_rounded, color: AppColors.teal, size: 22),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface2 : AppColors.muted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.notifications_outlined,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, size: 22),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded,
              color: isDark ? AppColors.darkTextHint : AppColors.textHint, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Xizmat, usta yoki kompaniya qidiring...',
                hintStyle: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextHint : AppColors.textHint),
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) => context.read<HomeBloc>().add(SearchProviders(v)),
            ),
          ),
          GestureDetector(
            onTap: _isListening ? _stopVoiceSearch : _startVoiceSearch,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isListening ? AppColors.error : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOrderHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: GestureDetector(
        onTap: () => context.push('/home/quick-order'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1557B0), Color(0xFF1A73E8), Color(0xFF4285F4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tezkor xizmat',
                      style: AppTextStyles.heading2(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Yaqin atrofdagi ustani darhol toping',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Hozir buyurtma',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded,
                              size: 14, color: AppColors.primary),
                        ],
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

  Widget _buildSecondaryCtaRow(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _SmallCtaCard(
              icon: Icons.calendar_today_rounded,
              label: 'Rejalas-\ntirilgan',
              color: AppColors.purple,
              bgColor: isDark ? const Color(0xFF2A1F4A) : AppColors.purpleLight,
              onTap: () => context.push('/home/scheduled-order'),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SmallCtaCard(
              icon: Icons.near_me_rounded,
              label: 'Yaqin\nustalar',
              color: AppColors.teal,
              bgColor: isDark ? const Color(0xFF0D2E2B) : AppColors.tealLight,
              onTap: () => context.push('/home/providers'),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SmallCtaCard(
              icon: Icons.business_rounded,
              label: 'Kompan-\niyalar',
              color: AppColors.orange,
              bgColor: isDark ? const Color(0xFF2E1A0A) : AppColors.orangeLight,
              onTap: () => context.push('/companies'),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SmallCtaCard(
              icon: Icons.gavel_rounded,
              label: 'Tender\nbuyurtma',
              color: const Color(0xFF0F9D58),
              bgColor: isDark ? const Color(0xFF0A2B1A) : const Color(0xFFE6F4EA),
              onTap: () => context.push('/tender-order'),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, HomeLoaded state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'Kategoriyalar',
            style: AppTextStyles.heading2(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length,
            separatorBuilder: (_, i) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = state.categories[index];
              return _CategoryChip(
                category: cat,
                isSelected: state.selectedCategoryId == cat.id,
                onTap: () => context.read<HomeBloc>().add(FilterByCategory(cat.id)),
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: LoadingShimmer(child: ShimmerBox(width: 130, height: 16)),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            separatorBuilder: (_, i) => const SizedBox(width: 8),
            itemBuilder: (_, i) => const ShimmerCategoryChip(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedProviders(BuildContext context, HomeLoaded state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tavsiya etilgan ustalar',
                  style: AppTextStyles.heading2(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              TextButton(
                onPressed: () => context.push('/home/providers'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text('Barchasi',
                    style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        if (state.suggestedProviders.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Bu kategoriyada ustalar topilmadi',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          )
        else
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.suggestedProviders.length,
              separatorBuilder: (_, i) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final provider = state.suggestedProviders[index];
                return ProviderCard(
                  provider: provider,
                  onTap: () => context.push('/home/providers/${provider.id}', extra: provider),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildProvidersShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: LoadingShimmer(child: ShimmerBox(width: 200, height: 16)),
        ),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 4,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (_, i) => const ShimmerProviderCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyProviders(BuildContext context, HomeLoaded state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yaqin ustalar',
                  style: AppTextStyles.heading2(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
              TextButton(
                onPressed: () => context.push('/home/providers'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text('Barchasi',
                    style: GoogleFonts.nunito(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: state.nearbyProviders
                .map((provider) => ProviderCard(
                      provider: provider,
                      isHorizontal: true,
                      onTap: () =>
                          context.push('/home/providers/${provider.id}', extra: provider),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  void _showLocationSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Manzilni tanlang',
                style: AppTextStyles.heading2(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...AppConstants.tashkentDistricts.take(6).map((district) => ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  title: Text('$district, Toshkent',
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
                  onTap: () => Navigator.pop(context),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
          ],
        ),
      ),
    );
  }
}

class _SmallCtaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final bool isDark;

  const _SmallCtaCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: isDark ? 0.25 : 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  height: 1.2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.border)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
