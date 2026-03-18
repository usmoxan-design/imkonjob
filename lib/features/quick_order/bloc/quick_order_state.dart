import 'package:equatable/equatable.dart';
import '../../../core/models/order_model.dart';

abstract class QuickOrderState extends Equatable {
  const QuickOrderState();

  @override
  List<Object?> get props => [];
}

class QuickOrderInitial extends QuickOrderState {
  const QuickOrderInitial();
}

class QuickOrderSubmitting extends QuickOrderState {
  const QuickOrderSubmitting();
}

class QuickOrderSearching extends QuickOrderState {
  final String orderId;
  const QuickOrderSearching(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class QuickOrderProposalsReceived extends QuickOrderState {
  final List<OrderProposalModel> proposals;
  final String orderId;
  const QuickOrderProposalsReceived({
    required this.proposals,
    required this.orderId,
  });

  @override
  List<Object?> get props => [proposals, orderId];
}

class QuickOrderConfirmed extends QuickOrderState {
  final OrderModel order;
  const QuickOrderConfirmed(this.order);

  @override
  List<Object?> get props => [order];
}

class QuickOrderError extends QuickOrderState {
  final String message;
  const QuickOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
