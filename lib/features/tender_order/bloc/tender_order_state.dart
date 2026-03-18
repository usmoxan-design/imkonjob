import 'package:equatable/equatable.dart';
import '../../../core/models/order_model.dart';

abstract class TenderOrderState extends Equatable {
  const TenderOrderState();
  @override
  List<Object?> get props => [];
}

class TenderOrderInitial extends TenderOrderState {
  const TenderOrderInitial();
}

class TenderOrderSubmitting extends TenderOrderState {
  const TenderOrderSubmitting();
}

class TenderOrderSubmitted extends TenderOrderState {
  final OrderModel order;
  const TenderOrderSubmitted(this.order);
  @override
  List<Object?> get props => [order];
}

class TenderProposalsReceived extends TenderOrderState {
  final List<OrderProposalModel> proposals;
  const TenderProposalsReceived(this.proposals);
  @override
  List<Object?> get props => [proposals];
}

class TenderOrderConfirmed extends TenderOrderState {
  const TenderOrderConfirmed();
}

class TenderOrderError extends TenderOrderState {
  final String message;
  const TenderOrderError(this.message);
  @override
  List<Object?> get props => [message];
}
