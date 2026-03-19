import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/quick_order_bloc.dart';
import '../bloc/quick_order_event.dart';
import '../bloc/quick_order_state.dart';

class QuickOrderWaitingScreen extends StatefulWidget {
  const QuickOrderWaitingScreen({super.key});

  @override
  State<QuickOrderWaitingScreen> createState() =>
      _QuickOrderWaitingScreenState();
}

class _QuickOrderWaitingScreenState extends State<QuickOrderWaitingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Provider is moving — simulate a nearby position
  final LatLng _userLocation = const LatLng(41.2995, 69.2401);
  final LatLng _providerLocation = const LatLng(41.3020, 69.2450);

  bool _providerFound = false;
  final String _providerName = 'Jasur Toshmatov';
  final String _providerEta = '8 daqiqa';
  final double _providerRating = 4.8;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate finding provider after 3s
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _providerFound = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<QuickOrderBloc, QuickOrderState>(
      listener: (context, state) {
        if (state is QuickOrderProposalsReceived) {
          context.go('/home/quick-order/proposals');
        } else if (state is QuickOrderInitial) {
          context.go('/home/quick-order');
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        body: Stack(
          children: [
            _buildMap(),
            _buildTopBar(context, isDark),
            _buildBottomPanel(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
          (_userLocation.latitude + _providerLocation.latitude) / 2,
          (_userLocation.longitude + _providerLocation.longitude) / 2,
        ),
        initialZoom: 14.5,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.imkonjob.app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _userLocation,
              width: 48,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2)
                  ],
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            if (_providerFound)
              Marker(
                point: _providerLocation,
                width: 56,
                height: 56,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (_, _) => Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9D58), Color(0xFF34A853)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2)
                        ],
                      ),
                      child:
                          const Icon(Icons.handyman_rounded, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_providerFound)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_providerLocation, _userLocation],
                strokeWidth: 4,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.muted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.arrow_back_ios_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _providerFound ? 'Usta kelmoqda' : 'Usta qidirilmoqda...',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (_providerFound)
                    Text(
                      'Taxminiy vaqt: $_providerEta',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: AppColors.success),
                    )
                  else
                    Text(
                      'Yaqin ustalar buyurtmangizni ko\'rmoqda',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            if (!_providerFound)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                  backgroundColor: isDark
                      ? AppColors.darkBorder
                      : AppColors.border,
                ),
              ),
            if (_providerFound)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.radio_button_checked,
                        size: 10, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text('Yo\'lda',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, bool isDark) {
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.28,
      maxChildSize: 0.65,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4))
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (!_providerFound) _buildSearchingContent(isDark),
                if (_providerFound) _buildProviderFoundContent(context, isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchingContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, _) => Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _pulseAnimation.value * 1.4,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: _pulseAnimation.value * 1.2,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.search_rounded,
                      size: 30, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Usta qidirilmoqda...',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Yaqin atrofdagi ustalar buyurtmangizni ko\'rmoqda',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            backgroundColor:
                isDark ? AppColors.darkBorder : AppColors.border,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              context.read<QuickOrderBloc>().add(const CancelSearch());
              context.go('/home/quick-order');
            },
            child: Text('Bekor qilish',
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderFoundContent(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    _providerName[0],
                    style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_providerName,
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 14, color: Color(0xFFFBBC04)),
                        const SizedBox(width: 3),
                        Text(_providerRating.toString(),
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Yo\'lda · $_providerEta',
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Chat',
                  color: AppColors.primary,
                  bgColor: isDark
                      ? AppColors.darkPrimaryLight
                      : AppColors.primaryLight,
                  onTap: () => context.push('/chat-list'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Qo\'ng\'iroq',
                  color: AppColors.success,
                  bgColor: AppColors.successLight,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.close_rounded,
                  label: 'Bekor',
                  color: AppColors.error,
                  bgColor: AppColors.errorLight,
                  onTap: () => _showCancelDialog(context, isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface2 : AppColors.muted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usta yetib kelgach, xizmat ko\'rsatish boshlanadi. Iltimos, kutib turing.',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text('Bekor qilish',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text('Buyurtmani bekor qilmoqchimisiz?',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Yo\'q',
                style: GoogleFonts.nunito(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<QuickOrderBloc>().add(const CancelSearch());
              context.go('/home');
            },
            child: Text('Ha, bekor qilish',
                style: GoogleFonts.nunito(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
