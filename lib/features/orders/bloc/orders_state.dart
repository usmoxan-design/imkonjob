import 'package:equatable/equatable.dart';
import '../../../core/models/order_model.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> activeOrders;
  final List<OrderModel> pastOrders;

  const OrdersLoaded({
    required this.activeOrders,
    required this.pastOrders,
  });

  @override
  List<Object?> get props => [activeOrders, pastOrders];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
