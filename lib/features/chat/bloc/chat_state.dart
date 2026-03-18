import 'package:equatable/equatable.dart';
import '../../../core/models/chat_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomModel> rooms;
  const ChatRoomsLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class MessagesLoaded extends ChatState {
  final ChatRoomModel room;
  const MessagesLoaded(this.room);

  @override
  List<Object?> get props => [room];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
