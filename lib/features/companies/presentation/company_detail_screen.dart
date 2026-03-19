import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/company_model.dart';

class CompanyDetailScreen extends StatefulWidget {
  final CompanyModel company;
  const CompanyDetailScreen({super.key, required this.company});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  CompanyModel get c => widget.company;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF8F9FB);
    final surf = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            leading: IconButton(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 16),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A237E),
                          const Color(0xFF3949AB),
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Logo
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2),
                          ),
                          child: Center(
                            child: Text(
                              c.name[0],
                              style: GoogleFonts.nunito(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.name,
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            if (c.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified_rounded,
                                  color: Color(0xFF64B5F6), size: 18),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.serviceCategories.take(2).join(' • '),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Stats bar
          SliverToBoxAdapter(
            child: Container(
              color: surf,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(
                      value: c.rating.toStringAsFixed(1),
                      label: 'Reyting',
                      icon: Icons.star_rounded,
                      color: const Color(0xFFFBBC04)),
                  _divider(),
                  _Stat(
                      value: '${c.reviewCount}',
                      label: 'Sharhlar',
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppColors.primary),
                  _divider(),
                  _Stat(
                      value: '${c.completedOrders}',
                      label: 'Buyurtmalar',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.success),
                  _divider(),
                  _Stat(
                      value: c.workingHours.split('–').first.trim(),
                      label: 'Ish vaqti',
                      icon: Icons.access_time_rounded,
                      color: AppColors.teal),
                ],
              ),
            ),
          ),
          // Tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tab,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor:
                    isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                indicatorWeight: 2.5,
                labelStyle: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'Ma\'lumot'),
                  Tab(text: 'Portfolio'),
                  Tab(text: 'Sharhlar'),
                ],
              ),
              isDark: isDark,
              surf: surf,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _InfoTab(company: c, isDark: isDark, surf: surf),
            _PortfolioTab(company: c, isDark: isDark),
            _ReviewsTab(isDark: isDark, surf: surf),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(company: c),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: AppColors.border);
}

class _Stat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;

  const _Stat(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
              fontSize: 11,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─── Info Tab ────────────────────────────────────────────────────────────────
class _InfoTab extends StatelessWidget {
  final CompanyModel company;
  final bool isDark;
  final Color surf;

  const _InfoTab(
      {required this.company, required this.isDark, required this.surf});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          surf: surf,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Tavsif', isDark),
              const SizedBox(height: 8),
              Text(
                company.description,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  height: 1.55,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          surf: surf,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Xizmatlar', isDark),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: company.serviceCategories
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkPrimaryLight
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          surf: surf,
          isDark: isDark,
          child: Column(
            children: [
              _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Manzil',
                  value: company.location,
                  isDark: isDark),
              _divider(isDark),
              _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: 'Ish vaqti',
                  value: company.workingHours,
                  isDark: isDark),
              _divider(isDark),
              _InfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Narx oralig\'i',
                  value: company.priceRange,
                  isDark: isDark),
              _divider(isDark),
              _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Telefon',
                  value: company.phone,
                  isDark: isDark),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _divider(bool isDark) => Divider(
        height: 1,
        color: isDark ? AppColors.darkBorder : AppColors.border,
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isDark;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextHint
                          : AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Portfolio Tab ────────────────────────────────────────────────────────────
class _PortfolioTab extends StatelessWidget {
  final CompanyModel company;
  final bool isDark;

  const _PortfolioTab({required this.company, required this.isDark});

  final List<String> _extraImages = const [
    'https://picsum.photos/seed/extra1/400/400',
    'https://picsum.photos/seed/extra2/400/400',
    'https://picsum.photos/seed/extra3/400/400',
    'https://picsum.photos/seed/extra4/400/400',
    'https://picsum.photos/seed/extra5/400/400',
    'https://picsum.photos/seed/extra6/400/400',
  ];

  @override
  Widget build(BuildContext context) {
    final images = [...company.portfolio, ..._extraImages];
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) {
        return GestureDetector(
          onTap: () => _openViewer(context, images, i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: images[i],
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                  color: isDark ? AppColors.darkSurface2 : AppColors.grey100),
              errorWidget: (_, _, _) => Container(
                  color: isDark ? AppColors.darkSurface2 : AppColors.grey100),
            ),
          ),
        );
      },
    );
  }

  void _openViewer(BuildContext context, List<String> images, int initial) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ImageViewer(images: images, initial: initial),
    ));
  }
}

class _ImageViewer extends StatefulWidget {
  final List<String> images;
  final int initial;

  const _ImageViewer({required this.images, required this.initial});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late int _current;
  late PageController _page;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
    _page = PageController(initialPage: widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.images.length}',
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
        ),
      ),
      body: PageView.builder(
        controller: _page,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => Center(
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: widget.images[i],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reviews Tab ──────────────────────────────────────────────────────────────
class _ReviewsTab extends StatelessWidget {
  final bool isDark;
  final Color surf;

  const _ReviewsTab({required this.isDark, required this.surf});

  static const _reviews = [
    (
      name: 'Sardor Toshmatov',
      text: 'Juda tez va sifatli xizmat. Ustalar o\'z ishini yaxshi biladi!',
      rating: 5,
      time: '2 kun oldin',
      avatar: 'https://i.pravatar.cc/150?img=11'
    ),
    (
      name: 'Malika Yusupova',
      text: 'Narxi maqul, natija a\'lo. Keyingi safar ham murojaat qilaman.',
      rating: 5,
      time: '5 kun oldin',
      avatar: 'https://i.pravatar.cc/150?img=21'
    ),
    (
      name: 'Bobur Karimov',
      text: 'Vaqtida kelishdi, ish sifati yaxshi. Lekin narxi bir oz qimmatroq.',
      rating: 4,
      time: '1 hafta oldin',
      avatar: 'https://i.pravatar.cc/150?img=32'
    ),
    (
      name: 'Nilufar Hasanova',
      text: 'Professional yondashuv. Barcha masalalarni hal qilishdi.',
      rating: 5,
      time: '2 hafta oldin',
      avatar: 'https://i.pravatar.cc/150?img=44'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final r = _reviews[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: r.avatar,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 40,
                        height: 40,
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (j) => Icon(
                                j < r.rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 14,
                                color: const Color(0xFFFBBC04),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              r.time,
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextHint
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                r.text,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final CompanyModel company;

  const _BottomBar({required this.company});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
            top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri(scheme: 'tel', path: company.phone);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
              icon: const Icon(Icons.phone_rounded, size: 18),
              label: Text('Qo\'ng\'iroq',
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _orderSheet(context),
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: Text('Buyurtma berish',
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _orderSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Xizmat tanlang',
              style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ...company.serviceCategories.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimaryLight
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.build_outlined,
                        size: 18, color: AppColors.primary),
                  ),
                  title: Text(
                    s,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.grey400),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/home/quick-order');
                  },
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Label(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.darkTextHint : AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color surf;
  final bool isDark;

  const _Card({required this.child, required this.surf, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: child,
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;
  final Color surf;

  _TabBarDelegate(this.tabBar, {required this.isDark, required this.surf});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: surf,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) =>
      old.isDark != isDark || old.surf != surf;
}
