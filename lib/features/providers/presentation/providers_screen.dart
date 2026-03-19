import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/osm_map_widget.dart';
import '../../../core/widgets/provider_card.dart';
import '../bloc/providers_bloc.dart';
import '../bloc/providers_event.dart';
import '../bloc/providers_state.dart';

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ProvidersBloc>().add(const LoadProviders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Ustalar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ro\'yxat'),
            Tab(text: 'Xarita'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (q) {
                if (q.isEmpty) {
                  context.read<ProvidersBloc>().add(const ClearFilters());
                } else {
                  context
                      .read<ProvidersBloc>()
                      .add(SearchProvidersByQuery(q));
                }
              },
              style: GoogleFonts.nunito(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Usta yoki kategoriya qidiring...',
                hintStyle: GoogleFonts.nunito(
                    fontSize: 14, color: context.txtSecondary),
                prefixIcon: Icon(Icons.search_rounded,
                    color: context.txtSecondary),
                filled: true,
                fillColor: context.surf,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderClr),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderClr),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          BlocBuilder<ProvidersBloc, ProvidersState>(
            builder: (context, state) {
              if (state is! ProvidersLoaded) return const SizedBox.shrink();
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MockData.categories.length + 1,
                  separatorBuilder: (_, i) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAll = state.selectedCategoryId == null;
                      return _FilterChip(
                        label: 'Barchasi',
                        isSelected: isAll,
                        onTap: () => context
                            .read<ProvidersBloc>()
                            .add(const ClearFilters()),
                      );
                    }
                    final cat = MockData.categories[index - 1];
                    final isSelected = state.selectedCategoryId == cat.id;
                    return _FilterChip(
                      label: '${cat.icon} ${cat.name}',
                      isSelected: isSelected,
                      onTap: () => context
                          .read<ProvidersBloc>()
                          .add(FilterProviders(categoryId: cat.id)),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListTab(),
                _buildMapTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTab() {
    return BlocBuilder<ProvidersBloc, ProvidersState>(
      builder: (context, state) {
        if (state is ProvidersLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (_, i) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerListTile(),
            ),
          );
        }
        if (state is ProvidersLoaded) {
          if (state.providers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_search_rounded,
                      size: 64, color: context.isDark ? AppColors.grey600 : AppColors.grey300),
                  const SizedBox(height: 16),
                  Text(
                    'Ustalar topilmadi',
                    style: AppTextStyles.heading3(color: context.txtSecondary),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProvidersBloc>().add(const LoadProviders());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.providers.length,
              itemBuilder: (context, index) {
                final provider = state.providers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProviderCard(
                    provider: provider,
                    isHorizontal: true,
                    onTap: () => context.push(
                      '/home/providers/${provider.id}',
                      extra: provider,
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMapTab() {
    return BlocBuilder<ProvidersBloc, ProvidersState>(
      builder: (context, state) {
        final providers = state is ProvidersLoaded ? state.providers : [];
        final positions = [
          const LatLng(41.2995, 69.2401),
          const LatLng(41.3050, 69.2350),
          const LatLng(41.2940, 69.2480),
          const LatLng(41.3100, 69.2600),
          const LatLng(41.2850, 69.2300),
          const LatLng(41.3020, 69.2700),
          const LatLng(41.2900, 69.2550),
        ];
        return OsmMapWidget(
          center: const LatLng(41.2995, 69.2401),
          zoom: 13.0,
          markers: List.generate(positions.length, (i) {
            final hasProvider = i < providers.length;
            return providerMarker(
              position: positions[i],
              onTap: hasProvider
                  ? () => context.push(
                        '/home/providers/${providers[i].id}',
                        extra: providers[i],
                      )
                  : () {},
              isOnline: hasProvider ? providers[i].isOnline : i % 2 == 0,
            );
          }),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtr', style: AppTextStyles.heading2()),
            const SizedBox(height: 16),
            Text('Masofa bo\'yicha',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.txtSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['2 km', '5 km', '10 km', 'Barchasi'].map((d) {
                return ActionChip(
                  label: Text(d),
                  onPressed: () {
                    final dist = d == 'Barchasi'
                        ? null
                        : double.tryParse(d.replaceAll(' km', ''));
                    context.read<ProvidersBloc>().add(
                          FilterProviders(maxDistance: dist),
                        );
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Reyting bo\'yicha',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.txtSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['4.0+', '4.5+', '4.8+'].map((r) {
                return ActionChip(
                  label: Text(r),
                  onPressed: () {
                    final rating =
                        double.tryParse(r.replaceAll('+', ''));
                    context.read<ProvidersBloc>().add(
                          FilterProviders(minRating: rating),
                        );
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : context.surf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : context.borderClr,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : context.txtPrimary,
          ),
        ),
      ),
    );
  }
}
