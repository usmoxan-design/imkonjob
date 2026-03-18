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
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthGuest || authState is AuthUnauthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Kirish'),
                      ),
                    ),
                  ],
                ),
              ),
            );
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
                      _buildHeader(user.name, user.phone),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 8),
                      _buildMenuSection(context, state),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              }
              return const Center(
                child: LoadingShimmer(child: ShimmerBox(width: 200, height: 20)),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name, String phone) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            phone,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Tasdiqlanmagan',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '5', label: 'Buyurtma'),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(value: '4.8', label: 'Reyting'),
          Container(width: 1, height: 40, color: AppColors.border),
          _StatItem(value: '2024', label: 'A\'zo bo\'lgan'),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, ProfileLoaded state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _menuItem(Icons.edit_outlined, 'Profilni tahrirlash',
              () => context.push('/profile/edit')),
          const Divider(height: 1, indent: 52),
          _menuItem(Icons.notifications_outlined, 'Bildirishnomalar',
              () => context.push('/notifications')),
          const Divider(height: 1, indent: 52),
          _menuItem(
              Icons.location_on_outlined, 'Manzillar', () {}),
          const Divider(height: 1, indent: 52),
          _menuItem(Icons.language_rounded, 'Til (O\'zbek)', () {}),
          const Divider(height: 1, indent: 52),
          _menuItem(Icons.lock_outline_rounded, 'Xavfsizlik', () {}),
          const Divider(height: 1, thickness: 4, color: AppColors.background),
          _menuItem(
            Icons.build_rounded,
            'Usta bo\'lib ishlash',
            () => context.push('/provider/onboarding'),
            color: AppColors.orange,
            bgColor: AppColors.orangeLight,
            subtitle: 'Daromad ishlang',
          ),
          const Divider(height: 1, indent: 52),
          _menuItem(
            Icons.business_rounded,
            'Kompaniya bo\'lib ishlash',
            () => context.push('/company/onboarding'),
            color: AppColors.purple,
            bgColor: AppColors.purpleLight,
          ),
          const Divider(height: 1, indent: 52),
          _menuItem(
            Icons.photo_library_outlined,
            'Ishlar lenti',
            () => context.push('/posts'),
          ),
          const Divider(height: 1, indent: 52),
          _menuItem(
            Icons.add_photo_alternate_outlined,
            'Post qo\'shish',
            () => context.push('/posts/create'),
            color: AppColors.teal,
            bgColor: AppColors.tealLight,
          ),
          const Divider(height: 1, thickness: 4, color: AppColors.background),
          _menuItem(
              Icons.headset_mic_outlined, 'Yordam', () {}),
          const Divider(height: 1, indent: 52),
          _menuItem(Icons.info_outline_rounded, 'Ilova haqida', () {}),
          const Divider(height: 1, thickness: 4, color: AppColors.background),
          _menuItem(
            Icons.logout_rounded,
            'Chiqish',
            () => _confirmLogout(context),
            color: AppColors.error,
            bgColor: const Color(0xFFFEF2F2),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color color = AppColors.primary,
    Color bgColor = AppColors.primaryLight,
    String? subtitle,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color == AppColors.error ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.grey400, size: 20),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chiqish',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('Hisobdan chiqishni xohlaysizmi?',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Bekor qilish',
                style: GoogleFonts.nunito(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: Text('Chiqish',
                style: GoogleFonts.nunito(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
