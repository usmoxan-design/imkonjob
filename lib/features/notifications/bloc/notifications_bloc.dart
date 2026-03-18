import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/notification_model.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  List<NotificationModel> _notifications = [];

  NotificationsBloc() : super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllRead>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    _notifications = List.from(MockData.notifications);
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final unread = _notifications.where((n) => !n.isRead).length;
    emit(NotificationsLoaded(notifications: _notifications, unreadCount: unread));
  }

  void _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationsState> emit,
  ) {
    _notifications = _notifications.map((n) {
      if (n.id == event.id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    final unread = _notifications.where((n) => !n.isRead).length;
    emit(NotificationsLoaded(notifications: _notifications, unreadCount: unread));
  }

  void _onMarkAllRead(MarkAllRead event, Emitter<NotificationsState> emit) {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(NotificationsLoaded(notifications: _notifications, unreadCount: 0));
  }
}
