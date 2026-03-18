import 'package:equatable/equatable.dart';

abstract class ProviderModeEvent extends Equatable {
  const ProviderModeEvent();

  @override
  List<Object?> get props => [];
}

class StartOnboarding extends ProviderModeEvent {
  const StartOnboarding();
}

class SubmitOnboarding extends ProviderModeEvent {
  final String bio;
  final String categoryId;
  final String location;
  final String workingHours;
  final bool hasTransport;

  const SubmitOnboarding({
    required this.bio,
    required this.categoryId,
    required this.location,
    required this.workingHours,
    required this.hasTransport,
  });

  @override
  List<Object?> get props =>
      [bio, categoryId, location, workingHours, hasTransport];
}

class ToggleOnlineStatus extends ProviderModeEvent {
  final String status; // 'online', 'busy', 'offline'
  const ToggleOnlineStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class LoadDashboard extends ProviderModeEvent {
  const LoadDashboard();
}

class AcceptOrder extends ProviderModeEvent {
  final String orderId;
  const AcceptOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RejectOrder extends ProviderModeEvent {
  final String orderId;
  const RejectOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
