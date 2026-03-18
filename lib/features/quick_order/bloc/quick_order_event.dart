import 'package:equatable/equatable.dart';

abstract class QuickOrderEvent extends Equatable {
  const QuickOrderEvent();

  @override
  List<Object?> get props => [];
}

class StartQuickOrder extends QuickOrderEvent {
  const StartQuickOrder();
}

class SubmitQuickOrder extends QuickOrderEvent {
  final String serviceType;
  final String description;
  final String address;
  final String urgency;

  const SubmitQuickOrder({
    required this.serviceType,
    required this.description,
    required this.address,
    required this.urgency,
  });

  @override
  List<Object?> get props => [serviceType, description, address, urgency];
}

class SelectProposal extends QuickOrderEvent {
  final String proposalId;
  const SelectProposal(this.proposalId);

  @override
  List<Object?> get props => [proposalId];
}

class CancelSearch extends QuickOrderEvent {
  const CancelSearch();
}
