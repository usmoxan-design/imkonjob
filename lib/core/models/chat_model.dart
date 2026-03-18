import 'package:equatable/equatable.dart';
import 'provider_model.dart';

class ChatMessageModel extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final bool isMe;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
    required this.isMe,
  });

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    bool? isMe,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isMe: isMe ?? this.isMe,
    );
  }

  @override
  List<Object?> get props => [id, senderId, text, timestamp, isRead, isMe];
}

class ChatRoomModel extends Equatable {
  final String id;
  final ProviderModel provider;
  final List<ChatMessageModel> messages;
  final ChatMessageModel? lastMessage;
  final int unreadCount;
  final String? orderId;

  const ChatRoomModel({
    required this.id,
    required this.provider,
    required this.messages,
    this.lastMessage,
    this.unreadCount = 0,
    this.orderId,
  });

  ChatRoomModel copyWith({
    String? id,
    ProviderModel? provider,
    List<ChatMessageModel>? messages,
    ChatMessageModel? lastMessage,
    int? unreadCount,
    String? orderId,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      messages: messages ?? this.messages,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  List<Object?> get props => [id, provider, messages, lastMessage, unreadCount, orderId];
}
