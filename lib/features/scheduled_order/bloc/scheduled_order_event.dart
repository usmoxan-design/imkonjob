import 'package:equatable/equatable.dart';

abstract class ScheduledOrderEvent extends Equatable {
  const ScheduledOrderEvent();

  @override
  List<Object?> get props => [];
}

class StartScheduledOrder extends ScheduledOrderEvent {
  const StartScheduledOrder();
}

class SubmitScheduledOrder extends ScheduledOrderEvent {
  final String serviceType;
  final String description;
  final String address;
  final DateTime scheduledAt;
  final double? budget;

  const SubmitScheduledOrder({
    required this.serviceType,
    required this.description,
    required this.address,
    required this.scheduledAt,
    this.budget,
  });

  @override
  List<Object?> get props =>
      [serviceType, description, address, scheduledAt, budget];
}

class SelectScheduledProposal extends ScheduledOrderEvent {
  final String proposalId;
  const SelectScheduledProposal(this.proposalId);

  @override
  List<Object?> get props => [proposalId];
}
