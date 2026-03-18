import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  const LoadOrders();
}

class FilterOrders extends OrdersEvent {
  final bool activeOnly;
  const FilterOrders({required this.activeOnly});

  @override
  List<Object?> get props => [activeOnly];
}
