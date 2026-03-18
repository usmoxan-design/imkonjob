import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatRooms extends ChatEvent {
  const LoadChatRooms();
}

class LoadMessages extends ChatEvent {
  final String roomId;
  const LoadMessages(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SendMessage extends ChatEvent {
  final String roomId;
  final String text;
  const SendMessage({required this.roomId, required this.text});

  @override
  List<Object?> get props => [roomId, text];
}

class MarkAsRead extends ChatEvent {
  final String roomId;
  const MarkAsRead(this.roomId);

  @override
  List<Object?> get props => [roomId];
}
