import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/company_model.dart';
import '../../../core/models/order_model.dart';
import 'company_mode_event.dart';
import 'company_mode_state.dart';

class CompanyModeBloc extends Bloc<CompanyModeEvent, CompanyModeState> {
  CompanyModeBloc() : super(const CompanyModeInitial()) {
    on<StartCompanyOnboarding>(_onStart);
    on<SubmitCompanyOnboarding>(_onSubmit);
    on<LoadCompanyDashboard>(_onLoadDashboard);
    on<AcceptLead>(_onAcceptLead);
    on<RejectLead>(_onRejectLead);
  }

  static const _mockCompany = CompanyModel(
    id: 'company_1',
    name: 'Pro Services Toshkent',
    logo: 'https://i.pravatar.cc/150?img=50',
    description:
        'Toshkentdagi eng ishonchli xizmat ko\'rsatish kompaniyasi. 50+ malakali ustalar.',
    isVerified: true,
    rating: 4.8,
    reviewCount: 312,
    serviceCategories: ['Santexnik', 'Elektrik', 'Remont', 'Tozalash'],
    location: 'Yunusobod, Toshkent',
    phone: '+998 71 234 56 78',
    workingHours: '08:00 - 22:00',
    completedOrders: 1240,
    priceRange: '50,000 - 500,000 so\'m',
    portfolio: [
      'https://picsum.photos/seed/comp1/400/300',
      'https://picsum.photos/seed/comp2/400/300',
      'https://picsum.photos/seed/comp3/400/300',
    ],
  );

  void _onStart(
      StartCompanyOnboarding event, Emitter<CompanyModeState> emit) {
    emit(const CompanyOnboardingInProgress(step: 0));
  }

  Future<void> _onSubmit(
    SubmitCompanyOnboarding event,
    Emitter<CompanyModeState> emit,
  ) async {
    emit(const CompanyOnboardingSubmitting());
    await Future.delayed(const Duration(seconds: 2));
    emit(const CompanyModeActive(_mockCompany));
  }

  Future<void> _onLoadDashboard(
    LoadCompanyDashboard event,
    Emitter<CompanyModeState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final activeOrders = MockData.orders
        .where((o) =>
            o.status == OrderStatus.inProgress ||
            o.status == OrderStatus.onTheWay ||
            o.status == OrderStatus.providerSelected)
        .take(3)
        .toList();
    final leads = MockData.orders
        .where((o) => o.status == OrderStatus.searching)
        .take(3)
        .toList();
    emit(CompanyDashboardLoaded(
      company: _mockCompany,
      activeOrders: activeOrders,
      leads: leads,
    ));
  }

  void _onAcceptLead(AcceptLead event, Emitter<CompanyModeState> emit) {
    if (state is CompanyDashboardLoaded) {
      final current = state as CompanyDashboardLoaded;
      final updatedLeads =
          current.leads.where((o) => o.id != event.leadId).toList();
      emit(CompanyDashboardLoaded(
        company: current.company,
        activeOrders: current.activeOrders,
        leads: updatedLeads,
      ));
    }
  }

  void _onRejectLead(RejectLead event, Emitter<CompanyModeState> emit) {
    if (state is CompanyDashboardLoaded) {
      final current = state as CompanyDashboardLoaded;
      final updatedLeads =
          current.leads.where((o) => o.id != event.leadId).toList();
      emit(CompanyDashboardLoaded(
        company: current.company,
        activeOrders: current.activeOrders,
        leads: updatedLeads,
      ));
    }
  }
}
