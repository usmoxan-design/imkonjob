import 'package:equatable/equatable.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/provider_model.dart';

abstract class ProviderModeState extends Equatable {
  const ProviderModeState();

  @override
  List<Object?> get props => [];
}

class ProviderModeInitial extends ProviderModeState {
  const ProviderModeInitial();
}

class OnboardingInProgress extends ProviderModeState {
  final int step;
  const OnboardingInProgress(this.step);

  @override
  List<Object?> get props => [step];
}

class ProviderModeActive extends ProviderModeState {
  final ProviderModel provider;
  final String onlineStatus;

  const ProviderModeActive({
    required this.provider,
    this.onlineStatus = 'online',
  });

  ProviderModeActive copyWith({
    ProviderModel? provider,
    String? onlineStatus,
  }) {
    return ProviderModeActive(
      provider: provider ?? this.provider,
      onlineStatus: onlineStatus ?? this.onlineStatus,
    );
  }

  @override
  List<Object?> get props => [provider, onlineStatus];
}

class ProviderDashboardLoaded extends ProviderModeState {
  final ProviderModel provider;
  final String onlineStatus;
  final List<OrderModel> incomingOrders;
  final int todayRequests;
  final double rating;
  final int completedOrders;

  const ProviderDashboardLoaded({
    required this.provider,
    required this.onlineStatus,
    required this.incomingOrders,
    required this.todayRequests,
    required this.rating,
    required this.completedOrders,
  });

  ProviderDashboardLoaded copyWith({
    ProviderModel? provider,
    String? onlineStatus,
    List<OrderModel>? incomingOrders,
    int? todayRequests,
    double? rating,
    int? completedOrders,
  }) {
    return ProviderDashboardLoaded(
      provider: provider ?? this.provider,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      todayRequests: todayRequests ?? this.todayRequests,
      rating: rating ?? this.rating,
      completedOrders: completedOrders ?? this.completedOrders,
    );
  }

  @override
  List<Object?> get props => [
        provider,
        onlineStatus,
        incomingOrders,
        todayRequests,
        rating,
        completedOrders,
      ];
}

class ProviderModeError extends ProviderModeState {
  final String message;
  const ProviderModeError(this.message);

  @override
  List<Object?> get props => [message];
}
