import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/order_model.dart';
import 'provider_mode_event.dart';
import 'provider_mode_state.dart';

class ProviderModeBloc extends Bloc<ProviderModeEvent, ProviderModeState> {
  ProviderModeBloc() : super(const ProviderModeInitial()) {
    on<StartOnboarding>(_onStartOnboarding);
    on<SubmitOnboarding>(_onSubmitOnboarding);
    on<ToggleOnlineStatus>(_onToggleStatus);
    on<LoadDashboard>(_onLoadDashboard);
    on<AcceptOrder>(_onAcceptOrder);
    on<RejectOrder>(_onRejectOrder);
  }

  void _onStartOnboarding(
      StartOnboarding event, Emitter<ProviderModeState> emit) {
    emit(const OnboardingInProgress(1));
  }

  Future<void> _onSubmitOnboarding(
    SubmitOnboarding event,
    Emitter<ProviderModeState> emit,
  ) async {
    emit(const OnboardingInProgress(5));
    await Future.delayed(const Duration(seconds: 1));
    final provider = MockData.providers.first.copyWith(
      categoryId: event.categoryId,
      bio: event.bio,
      location: event.location,
      workingHours: event.workingHours,
      hasTransport: event.hasTransport,
      isOnline: true,
    );
    emit(ProviderModeActive(provider: provider, onlineStatus: 'online'));
    add(const LoadDashboard());
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<ProviderModeState> emit,
  ) async {
    final provider = state is ProviderModeActive
        ? (state as ProviderModeActive).provider
        : state is ProviderDashboardLoaded
            ? (state as ProviderDashboardLoaded).provider
            : MockData.providers.first;

    final onlineStatus = state is ProviderModeActive
        ? (state as ProviderModeActive).onlineStatus
        : state is ProviderDashboardLoaded
            ? (state as ProviderDashboardLoaded).onlineStatus
            : 'online';

    final incoming = MockData.orders
        .where((o) => o.status == OrderStatus.searching)
        .toList();

    emit(ProviderDashboardLoaded(
      provider: provider,
      onlineStatus: onlineStatus,
      incomingOrders: incoming,
      todayRequests: 7,
      rating: provider.rating,
      completedOrders: provider.completedOrders,
    ));
  }

  void _onToggleStatus(
    ToggleOnlineStatus event,
    Emitter<ProviderModeState> emit,
  ) {
    if (state is ProviderDashboardLoaded) {
      final current = state as ProviderDashboardLoaded;
      emit(current.copyWith(onlineStatus: event.status));
    } else if (state is ProviderModeActive) {
      final current = state as ProviderModeActive;
      emit(current.copyWith(onlineStatus: event.status));
    }
  }

  void _onAcceptOrder(AcceptOrder event, Emitter<ProviderModeState> emit) {
    if (state is! ProviderDashboardLoaded) return;
    final current = state as ProviderDashboardLoaded;
    final updated = current.incomingOrders
        .where((o) => o.id != event.orderId)
        .toList();
    emit(current.copyWith(incomingOrders: updated));
  }

  void _onRejectOrder(RejectOrder event, Emitter<ProviderModeState> emit) {
    if (state is! ProviderDashboardLoaded) return;
    final current = state as ProviderDashboardLoaded;
    final updated = current.incomingOrders
        .where((o) => o.id != event.orderId)
        .toList();
    emit(current.copyWith(incomingOrders: updated));
  }
}
