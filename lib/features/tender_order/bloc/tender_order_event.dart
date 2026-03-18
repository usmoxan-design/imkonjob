import 'package:equatable/equatable.dart';

abstract class TenderOrderEvent extends Equatable {
  const TenderOrderEvent();
  @override
  List<Object?> get props => [];
}

class SubmitTenderOrder extends TenderOrderEvent {
  final String serviceType;
  final String description;
  final String address;
  final String? budget;
  final DateTime deadline;

  const SubmitTenderOrder({
    required this.serviceType,
    required this.description,
    required this.address,
    this.budget,
    required this.deadline,
  });

  @override
  List<Object?> get props =>
      [serviceType, description, address, budget, deadline];
}

class SelectTenderProposal extends TenderOrderEvent {
  final String proposalId;
  const SelectTenderProposal(this.proposalId);
  @override
  List<Object?> get props => [proposalId];
}

class ResetTenderOrder extends TenderOrderEvent {
  const ResetTenderOrder();
}
