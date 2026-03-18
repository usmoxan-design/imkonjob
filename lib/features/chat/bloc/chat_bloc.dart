import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/chat_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  List<ChatRoomModel> _rooms = [];

  ChatBloc() : super(const ChatInitial()) {
    on<LoadChatRooms>(_onLoadChatRooms);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRooms event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    _rooms = List.from(MockData.chatRooms);
    emit(ChatRoomsLoaded(List.from(_rooms)));
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    final room = _rooms.firstWhere(
      (r) => r.id == event.roomId,
      orElse: () => MockData.chatRooms.first,
    );
    // Mark all as read
    final updatedMessages = room.messages
        .map((m) => m.copyWith(isRead: true))
        .toList();
    final updatedRoom = room.copyWith(messages: updatedMessages, unreadCount: 0);
    _rooms = _rooms.map((r) => r.id == event.roomId ? updatedRoom : r).toList();
    emit(MessagesLoaded(updatedRoom));
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final roomIndex = _rooms.indexWhere((r) => r.id == event.roomId);
    if (roomIndex == -1) return;

    const uuid = Uuid();
    final newMessage = ChatMessageModel(
      id: uuid.v4(),
      senderId: 'me',
      text: event.text,
      timestamp: DateTime.now(),
      isRead: true,
      isMe: true,
    );

    final room = _rooms[roomIndex];
    final updatedMessages = [...room.messages, newMessage];
    final updatedRoom = room.copyWith(
      messages: updatedMessages,
      lastMessage: newMessage,
    );
    _rooms[roomIndex] = updatedRoom;
    emit(MessagesLoaded(updatedRoom));

    // Simulate a reply after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    final replies = [
      'Yaxshi, tushundim.',
      'Hozir qarayman.',
      'Mayli, bo\'ladi.',
      'Rahmat xabar uchun!',
      '5 daqiqada hal qilaman.',
    ];
    final reply = ChatMessageModel(
      id: uuid.v4(),
      senderId: room.provider.id,
      text: replies[DateTime.now().second % replies.length],
      timestamp: DateTime.now(),
      isRead: false,
      isMe: false,
    );
    final withReply = [...updatedMessages, reply];
    final roomWithReply = updatedRoom.copyWith(
      messages: withReply,
      lastMessage: reply,
    );
    _rooms[roomIndex] = roomWithReply;
    emit(MessagesLoaded(roomWithReply));
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<ChatState> emit,
  ) async {
    final roomIndex = _rooms.indexWhere((r) => r.id == event.roomId);
    if (roomIndex == -1) return;
    final room = _rooms[roomIndex];
    final updatedMessages =
        room.messages.map((m) => m.copyWith(isRead: true)).toList();
    final updatedRoom =
        room.copyWith(messages: updatedMessages, unreadCount: 0);
    _rooms[roomIndex] = updatedRoom;
    emit(ChatRoomsLoaded(List.from(_rooms)));
  }
}
