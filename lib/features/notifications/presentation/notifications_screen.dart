import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/notification_model.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const LoadNotifications());
  }

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
        title: Text(
          'Bildirishnomalar',
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<NotificationsBloc>().add(const MarkAllRead()),
            child: Text(
              'Barchasini o\'qildi',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return _buildShimmer(isDark);
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmpty(isDark);
            }

            // Group by date
            final today = <NotificationModel>[];
            final yesterday = <NotificationModel>[];
            final older = <NotificationModel>[];
            final now = DateTime.now();
            for (final n in state.notifications) {
              final diff = now.difference(n.createdAt).inDays;
              if (diff == 0) {
                today.add(n);
              } else if (diff == 1) {
                yesterday.add(n);
              } else {
                older.add(n);
              }
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (today.isNotEmpty) ...[
                  _sectionHeader('Bugun', isDark),
                  ...today.map((n) => _NotifTile(
                      notification: n,
                      isDark: isDark,
                      surf: surf,
                      onTap: () => context
                          .read<NotificationsBloc>()
                          .add(MarkNotificationRead(n.id)))),
                ],
                if (yesterday.isNotEmpty) ...[
                  _sectionHeader('Kecha', isDark),
                  ...yesterday.map((n) => _NotifTile(
                      notification: n,
                      isDark: isDark,
                      surf: surf,
                      onTap: () => context
                          .read<NotificationsBloc>()
                          .add(MarkNotificationRead(n.id)))),
                ],
                if (older.isNotEmpty) ...[
                  _sectionHeader('Oldingi', isDark),
                  ...older.map((n) => _NotifTile(
                      notification: n,
                      isDark: isDark,
                      surf: surf,
                      onTap: () => context
                          .read<NotificationsBloc>()
                          .add(MarkNotificationRead(n.id)))),
                ],
                const SizedBox(height: 24),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextHint : AppColors.grey500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 40,
              color: isDark ? AppColors.darkTextHint : AppColors.grey400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Bildirishnomalar yo\'q',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Yangi buyurtmalar va xabarlar\nbuyerda ko\'rinadi',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(12))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 13,
                      width: 160,
                      color:
                          isDark ? AppColors.darkSurface2 : AppColors.grey100),
                  const SizedBox(height: 8),
                  Container(
                      height: 11,
                      width: 220,
                      color:
                          isDark ? AppColors.darkSurface2 : AppColors.grey100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notification;
  final bool isDark;
  final Color surf;
  final VoidCallback onTap;

  const _NotifTile({
    required this.notification,
    required this.isDark,
    required this.surf,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _getConfig();
    final isRead = notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error.withValues(alpha: 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text('O\'chir',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => context
          .read<NotificationsBloc>()
          .add(MarkNotificationRead(notification.id)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 2, 12, 2),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead
                ? surf
                : (isDark
                    ? AppColors.darkPrimaryLight.withValues(alpha: 0.5)
                    : AppColors.primaryLight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRead
                  ? (isDark ? AppColors.darkBorder : AppColors.border)
                  : AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cfg.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cfg.icon, color: cfg.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight:
                                  isRead ? FontWeight.w600 : FontWeight.w800,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(notification.createdAt),
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextHint
                                : AppColors.grey500,
                          ),
                        ),
                        if (!isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  _NotifConfig _getConfig() {
    switch (notification.type) {
      case NotificationType.order:
        return _NotifConfig(
          icon: Icons.assignment_rounded,
          color: AppColors.primary,
          bgColor: AppColors.primaryLight,
        );
      case NotificationType.proposal:
        return _NotifConfig(
          icon: Icons.person_pin_rounded,
          color: AppColors.orange,
          bgColor: AppColors.orangeLight,
        );
      case NotificationType.message:
        return _NotifConfig(
          icon: Icons.chat_bubble_rounded,
          color: AppColors.teal,
          bgColor: AppColors.tealLight,
        );
      case NotificationType.system:
        return _NotifConfig(
          icon: Icons.campaign_rounded,
          color: AppColors.purple,
          bgColor: AppColors.purpleLight,
        );
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}s';
    if (diff.inDays == 1) return 'Kecha';
    return DateFormat('dd MMM').format(dt);
  }
}

class _NotifConfig {
  final IconData icon;
  final Color color;
  final Color bgColor;

  _NotifConfig(
      {required this.icon, required this.color, required this.bgColor});
}
