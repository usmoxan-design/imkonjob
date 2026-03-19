import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _darkModeEnabled = Theme.of(context).brightness == Brightness.dark;
  }

  final List<Map<String, dynamic>> _savedLocations = [
    {
      'name': 'Uyim',
      'address': 'Yunusobod 11-kvartal, Toshkent',
      'icon': Icons.home_rounded,
      'color': AppColors.primary
    },
    {
      'name': 'Ishxonam',
      'address': 'Amir Temur ko\'chasi 108, Toshkent',
      'icon': Icons.work_rounded,
      'color': AppColors.teal
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF8F9FB);
    final surf = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profil',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthGuest || authState is AuthUnauthenticated) {
            return _buildGuest(context, isDark, surf);
          }
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ProfileLoaded) {
                final user = state.user;
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(user.name, user.phone, isDark, surf),
                      const SizedBox(height: 12),
                      _buildStatsRow(isDark, surf),
                      const SizedBox(height: 12),
                      _buildModeCards(context, isDark),
                      const SizedBox(height: 12),
                      _buildMenuSection(context, state, isDark, surf),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }
              return const Center(
                child: LoadingShimmer(
                    child: ShimmerBox(width: 200, height: 20)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGuest(BuildContext context, bool isDark, Color surf) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded,
                  size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Profilingizga kirish uchun\nhisobga kiring',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Kirish',
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      String name, String phone, bool isDark, Color surf) {
    return Container(
      width: double.infinity,
      color: surf,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: GoogleFonts.nunito(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/profile/edit'),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDark ? AppColors.darkBackground : Colors.white,
                        width: 2),
                  ),
                  child:
                      const Icon(Icons.edit_rounded, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            phone,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Badge(
                icon: Icons.shield_outlined,
                label: 'Tasdiqlanmagan',
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                bg: isDark ? AppColors.darkSurface2 : AppColors.grey100,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _Badge(
                icon: Icons.star_rounded,
                label: '4.8',
                color: const Color(0xFFF9A825),
                bg: const Color(0xFFFFF8E1),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, Color surf) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              value: '5',
              label: 'Buyurtma',
              isDark: isDark),
          Container(
              width: 1,
              height: 40,
              color: isDark ? AppColors.darkBorder : AppColors.border),
          _StatItem(
              value: '4.8',
              label: 'Reyting',
              isDark: isDark),
          Container(
              width: 1,
              height: 40,
              color: isDark ? AppColors.darkBorder : AppColors.border),
          _StatItem(
              value: '2024',
              label: 'A\'zo bo\'lgan',
              isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildModeCards(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _ModeCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.build_rounded,
            title: 'Usta bo\'lib ishlash',
            subtitle: 'O\'z xizmatlaringizni taklif qiling va daromad ishlang',
            badge: 'YANGI',
            onTap: () => context.push('/provider/onboarding'),
          ),
          const SizedBox(height: 10),
          _ModeCard(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9F67F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            icon: Icons.business_rounded,
            title: 'Kompaniya bo\'lib ishlash',
            subtitle:
                'Kompaniyangizni ro\'yxatdan o\'tkazing va buyurtmalar oling',
            badge: 'PRO',
            onTap: () => context.push('/company/onboarding'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, ProfileLoaded state,
      bool isDark, Color surf) {
    final grp1 = [
      _MenuEntry(
          icon: Icons.edit_outlined,
          title: 'Profilni tahrirlash',
          onTap: () => context.push('/profile/edit')),
      _MenuEntry(
          icon: Icons.notifications_outlined,
          title: 'Bildirishnomalar',
          onTap: () => context.push('/notifications')),
      _MenuEntry(
          icon: Icons.location_on_outlined,
          title: 'Manzillarim',
          onTap: () => _showSavedLocationsSheet(context, isDark)),
    ];

    final grp2 = [
      _MenuEntry(
          icon: Icons.language_rounded,
          title: 'Til',
          trailing: _LangBadge(isDark: isDark),
          onTap: () => _showLangSheet(context, isDark)),
      _MenuEntry(
          icon: Icons.dark_mode_outlined,
          title: 'Qorong\'u rejim',
          trailing: Switch(
            value: _darkModeEnabled,
            onChanged: (v) {
              setState(() => _darkModeEnabled = v);
              _showDarkModeNote(context);
            },
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onTap: null),
      _MenuEntry(
          icon: Icons.lock_outline_rounded,
          title: 'Xavfsizlik',
          onTap: () => _showSecuritySheet(context, isDark)),
    ];

    final grp3 = [
      _MenuEntry(
          icon: Icons.add_photo_alternate_outlined,
          title: 'Post qo\'shish',
          color: AppColors.teal,
          bgColor: AppColors.tealLight,
          onTap: () => context.push('/posts/create')),
    ];

    final grp4 = [
      _MenuEntry(
          icon: Icons.headset_mic_outlined,
          title: 'Yordam markazi',
          onTap: () {}),
      _MenuEntry(
          icon: Icons.info_outline_rounded,
          title: 'Ilova haqida',
          onTap: () => _showAboutSheet(context, isDark)),
    ];

    final grp5 = [
      _MenuEntry(
          icon: Icons.logout_rounded,
          title: 'Chiqish',
          color: AppColors.error,
          bgColor: const Color(0xFFFEF2F2),
          onTap: () => _confirmLogout(context, isDark)),
    ];

    return Column(
      children: [
        _MenuGroup(entries: grp1, isDark: isDark, surf: surf),
        const SizedBox(height: 10),
        _MenuGroup(entries: grp2, isDark: isDark, surf: surf),
        const SizedBox(height: 10),
        _MenuGroup(entries: grp3, isDark: isDark, surf: surf),
        const SizedBox(height: 10),
        _MenuGroup(entries: grp4, isDark: isDark, surf: surf),
        const SizedBox(height: 10),
        _MenuGroup(entries: grp5, isDark: isDark, surf: surf),
      ],
    );
  }

  void _showSavedLocationsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Manzillarim',
                        style: GoogleFonts.nunito(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)),
                    TextButton.icon(
                      onPressed: () =>
                          _showAddLocationDialog(context, setModal, isDark),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text('Qo\'shish',
                          style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              ..._savedLocations.map(
                (loc) => ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (loc['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(loc['icon'] as IconData,
                        color: loc['color'] as Color, size: 20),
                  ),
                  title: Text(loc['name'] as String,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary)),
                  subtitle: Text(loc['address'] as String,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 20),
                    onPressed: () {
                      setModal(() => _savedLocations.remove(loc));
                      setState(() {});
                    },
                  ),
                ),
              ),
              if (_savedLocations.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('Hech qanday manzil saqlanmagan',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLocationDialog(
      BuildContext context, StateSetter setModal, bool isDark) {
    final nameCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Yangi manzil',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _inputField(nameCtrl, 'Nom (masalan: Uyim)', isDark),
            const SizedBox(height: 12),
            _inputField(addrCtrl, 'Manzil', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Bekor',
                style: GoogleFonts.nunito(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty &&
                  addrCtrl.text.trim().isNotEmpty) {
                setModal(() => _savedLocations.add({
                      'name': nameCtrl.text.trim(),
                      'address': addrCtrl.text.trim(),
                      'icon': Icons.location_on_rounded,
                      'color': AppColors.orange,
                    }));
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Saqlash',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint, bool isDark) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.nunito(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextHint : AppColors.textHint),
        filled: true,
        fillColor: isDark ? AppColors.darkBackground : AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  void _showLangSheet(BuildContext context, bool isDark) {
    final langs = [
      ('🇺🇿', 'O\'zbek tili', 'uz'),
      ('🇷🇺', 'Русский', 'ru'),
      ('🇬🇧', 'English', 'en'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Til tanlash',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...langs.map(
              (l) => ListTile(
                leading: Text(l.$1,
                    style: const TextStyle(fontSize: 24)),
                title: Text(l.$2,
                    style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary)),
                trailing: l.$3 == 'uz'
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l.$2} tanlandi',
                          style: GoogleFonts.nunito()),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSecuritySheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Xavfsizlik',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary)),
            const SizedBox(height: 16),
            _secItem(Icons.phone_android_rounded, 'Telefon raqamni o\'zgartirish', isDark),
            _secItem(Icons.lock_reset_rounded, 'Parolni o\'zgartirish', isDark),
            _secItem(Icons.fingerprint_rounded, 'Biometrik kirish', isDark),
            _secItem(Icons.delete_forever_outlined, 'Hisobni o\'chirish', isDark,
                color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _secItem(IconData icon, String title, bool isDark,
      {Color color = AppColors.primary}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color == AppColors.error
                ? AppColors.error
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.grey400, size: 18),
      onTap: () {},
    );
  }

  void _showAboutSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.handyman_rounded,
                  color: Colors.white, size: 34),
            ),
            const SizedBox(height: 12),
            Text('Imkon Job',
                style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary)),
            Text('Versiya 1.0.0',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text(
              'O\'zbekistondagi yagona xizmatlar marketpleysi.\nUstalar va mijozlarni bir platformada birlashtiradi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showDarkModeNote(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Qurilma tizim sozlamalaridan qorong\'u rejimni yoqing',
          style: GoogleFonts.nunito(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _confirmLogout(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Chiqish',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary)),
        content: Text('Hisobdan chiqishni xohlaysizmi?',
            style: GoogleFonts.nunito(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Bekor',
                style: GoogleFonts.nunito(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Chiqish',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final bool isDark;

  const _Badge(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
                fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _LangBadge extends StatelessWidget {
  final bool isDark;

  const _LangBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇺🇿', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            'O\'zbek',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String title;
  final Color color;
  final Color bgColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuEntry({
    required this.icon,
    required this.title,
    this.color = AppColors.primary,
    this.bgColor = AppColors.primaryLight,
    this.trailing,
    required this.onTap,
  });
}

class _MenuGroup extends StatelessWidget {
  final List<_MenuEntry> entries;
  final bool isDark;
  final Color surf;

  const _MenuGroup(
      {required this.entries, required this.isDark, required this.surf});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          return Column(
            children: [
              ListTile(
                onTap: e.onTap,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? e.bgColor.withValues(alpha: 0.25)
                        : e.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.icon, size: 18, color: e.color),
                ),
                title: Text(
                  e.title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: e.color == AppColors.error
                        ? AppColors.error
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                  ),
                ),
                trailing: e.trailing ??
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.grey400, size: 18),
              ),
              if (i < entries.length - 1)
                Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _ModeCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(badge,
                            style: GoogleFonts.nunito(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatItem(
      {required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary)),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary)),
      ],
    );
  }
}
