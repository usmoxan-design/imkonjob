import 'package:equatable/equatable.dart';
import '../../../core/models/company_model.dart';
import '../../../core/models/order_model.dart';

abstract class CompanyModeState extends Equatable {
  const CompanyModeState();
  @override
  List<Object?> get props => [];
}

class CompanyModeInitial extends CompanyModeState {
  const CompanyModeInitial();
}

class CompanyOnboardingInProgress extends CompanyModeState {
  final int step;
  const CompanyOnboardingInProgress({required this.step});
  @override
  List<Object?> get props => [step];
}

class CompanyOnboardingSubmitting extends CompanyModeState {
  const CompanyOnboardingSubmitting();
}

class CompanyModeActive extends CompanyModeState {
  final CompanyModel company;
  const CompanyModeActive(this.company);
  @override
  List<Object?> get props => [company];
}

class CompanyDashboardLoaded extends CompanyModeState {
  final CompanyModel company;
  final List<OrderModel> activeOrders;
  final List<OrderModel> leads;

  const CompanyDashboardLoaded({
    required this.company,
    required this.activeOrders,
    required this.leads,
  });

  @override
  List<Object?> get props => [company, activeOrders, leads];
}

class CompanyModeError extends CompanyModeState {
  final String message;
  const CompanyModeError(this.message);
  @override
  List<Object?> get props => [message];
}
