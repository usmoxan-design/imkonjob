import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/widgets/loading_shimmer.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Xabarlar')),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return ListView.builder(
              itemCount: 4,
              itemBuilder: (_, i) => const ShimmerListTile(),
            );
          }
          if (state is ChatRoomsLoaded) {
            if (state.rooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_bubble_outline_rounded,
                        size: 72, color: AppColors.grey300),
                    const SizedBox(height: 16),
                    Text(
                      'Xabarlar yo\'q',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: state.rooms.length,
              separatorBuilder: (_, i) =>
                  const Divider(height: 1, indent: 78),
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                return _ChatRoomTile(
                  room: room,
                  onTap: () => context.push(
                    '/chat/${room.id}',
                    extra: room,
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final VoidCallback onTap;

  const _ChatRoomTile({required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lastMsg = room.lastMessage;
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: room.provider.avatar,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              placeholder: (_, u) => Container(color: AppColors.grey200),
              errorWidget: (_, u, e) => Container(
                  color: AppColors.grey200,
                  child: const Icon(Icons.person, size: 28)),
            ),
          ),
          if (room.provider.isOnline)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        room.provider.name,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight:
              room.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        lastMsg?.text ?? '',
        style: GoogleFonts.nunito(
          fontSize: 13,
          color: room.unreadCount > 0
              ? AppColors.textPrimary
              : AppColors.textSecondary,
          fontWeight: room.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (lastMsg != null)
            Text(
              _formatTime(lastMsg.timestamp),
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: room.unreadCount > 0
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: room.unreadCount > 0
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          const SizedBox(height: 4),
          if (room.unreadCount > 0)
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${room.unreadCount}',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
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
