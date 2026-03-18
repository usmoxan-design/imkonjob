import 'package:equatable/equatable.dart';
import '../../../core/models/order_model.dart';

abstract class ScheduledOrderState extends Equatable {
  const ScheduledOrderState();

  @override
  List<Object?> get props => [];
}

class ScheduledOrderInitial extends ScheduledOrderState {
  const ScheduledOrderInitial();
}

class ScheduledOrderSubmitting extends ScheduledOrderState {
  const ScheduledOrderSubmitting();
}

class ScheduledOrderProposalsReceived extends ScheduledOrderState {
  final List<OrderProposalModel> proposals;
  final String orderId;

  const ScheduledOrderProposalsReceived({
    required this.proposals,
    required this.orderId,
  });

  @override
  List<Object?> get props => [proposals, orderId];
}

class ScheduledOrderConfirmed extends ScheduledOrderState {
  final OrderModel order;
  const ScheduledOrderConfirmed(this.order);

  @override
  List<Object?> get props => [order];
}

class ScheduledOrderError extends ScheduledOrderState {
  final String message;
  const ScheduledOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
