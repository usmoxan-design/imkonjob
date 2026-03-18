import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/order_model.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(const OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<FilterOrders>(_onFilterOrders);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    final all = MockData.orders;
    final activeStatuses = {
      OrderStatus.searching,
      OrderStatus.proposalsReceived,
      OrderStatus.providerSelected,
      OrderStatus.onTheWay,
      OrderStatus.arrived,
      OrderStatus.inProgress,
    };
    final active = all.where((o) => activeStatuses.contains(o.status)).toList();
    final past = all
        .where((o) =>
            o.status == OrderStatus.completed ||
            o.status == OrderStatus.cancelled)
        .toList();
    emit(OrdersLoaded(activeOrders: active, pastOrders: past));
  }

  void _onFilterOrders(FilterOrders event, Emitter<OrdersState> emit) {
    if (state is! OrdersLoaded) return;
  }
}
