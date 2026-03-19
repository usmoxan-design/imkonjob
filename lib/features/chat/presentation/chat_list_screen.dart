import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/widgets/auth_required_widget.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const LoadChatRooms());
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
          'Xabarlar',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      body: AuthRequiredWidget(
        message: "Xabarlarni ko'rish uchun kiring",
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoading) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface2
                                  : AppColors.grey100,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                height: 13,
                                width: 130,
                                color: isDark
                                    ? AppColors.darkSurface2
                                    : AppColors.grey100),
                            const SizedBox(height: 8),
                            Container(
                                height: 11,
                                width: 200,
                                color: isDark
                                    ? AppColors.darkSurface2
                                    : AppColors.grey100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is ChatRoomsLoaded) {
              if (state.rooms.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.darkSurface : AppColors.grey100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 38,
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.grey400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Xabarlar yo\'q',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Buyurtma berganingizdan so\'ng\nusta bilan yozishish mumkin',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.rooms.length,
                separatorBuilder: (_, i) => Divider(
                  height: 1,
                  indent: 82,
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return _ChatRoomTile(
                    room: room,
                    isDark: isDark,
                    onTap: () =>
                        context.push('/chat/${room.id}', extra: room),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final bool isDark;
  final VoidCallback onTap;

  const _ChatRoomTile(
      {required this.room, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lastMsg = room.lastMessage;
    final hasUnread = room.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: room.provider.avatar,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppColors.primaryLight,
                        child: Center(
                          child: Text(
                            room.provider.name.isNotEmpty
                                ? room.provider.name[0]
                                : 'U',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.primaryLight,
                        child: const Icon(Icons.person,
                            size: 26, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                if (room.provider.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkBackground
                                : Colors.white,
                            width: 2),
                      ),
                    ),
                  ),
              ],
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
                          room.provider.name,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (lastMsg != null)
                        Text(
                          _formatTime(lastMsg.timestamp),
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: hasUnread
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.darkTextHint
                                    : AppColors.grey500),
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMsg?.text ?? '',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: hasUnread
                                ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return DateFormat('HH:mm').format(dt);
    } else if (now.difference(dt).inDays == 1) {
      return 'Kecha';
    }
    return DateFormat('dd.MM').format(dt);
  }
}
