import 'package:equatable/equatable.dart';

abstract class CompanyModeEvent extends Equatable {
  const CompanyModeEvent();
  @override
  List<Object?> get props => [];
}

class StartCompanyOnboarding extends CompanyModeEvent {
  const StartCompanyOnboarding();
}

class SubmitCompanyOnboarding extends CompanyModeEvent {
  final Map<String, dynamic> data;
  const SubmitCompanyOnboarding(this.data);
  @override
  List<Object?> get props => [data];
}

class LoadCompanyDashboard extends CompanyModeEvent {
  const LoadCompanyDashboard();
}

class AcceptLead extends CompanyModeEvent {
  final String leadId;
  const AcceptLead(this.leadId);
  @override
  List<Object?> get props => [leadId];
}

class RejectLead extends CompanyModeEvent {
  final String leadId;
  const RejectLead(this.leadId);
  @override
  List<Object?> get props => [leadId];
}
