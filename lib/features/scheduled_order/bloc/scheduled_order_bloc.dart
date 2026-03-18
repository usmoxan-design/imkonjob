import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/order_model.dart';
import 'scheduled_order_event.dart';
import 'scheduled_order_state.dart';

class ScheduledOrderBloc
    extends Bloc<ScheduledOrderEvent, ScheduledOrderState> {
  ScheduledOrderBloc() : super(const ScheduledOrderInitial()) {
    on<StartScheduledOrder>(_onStart);
    on<SubmitScheduledOrder>(_onSubmit);
    on<SelectScheduledProposal>(_onSelectProposal);
  }

  void _onStart(StartScheduledOrder event, Emitter<ScheduledOrderState> emit) {
    emit(const ScheduledOrderInitial());
  }

  Future<void> _onSubmit(
    SubmitScheduledOrder event,
    Emitter<ScheduledOrderState> emit,
  ) async {
    emit(const ScheduledOrderSubmitting());
    await Future.delayed(const Duration(seconds: 2));
    const uuid = Uuid();
    final orderId = uuid.v4();
    final proposals = MockData.getMockProposals(orderId);
    emit(ScheduledOrderProposalsReceived(
      proposals: proposals,
      orderId: orderId,
    ));
  }

  void _onSelectProposal(
    SelectScheduledProposal event,
    Emitter<ScheduledOrderState> emit,
  ) {
    if (state is! ScheduledOrderProposalsReceived) return;
    final current = state as ScheduledOrderProposalsReceived;
    final proposal = current.proposals.firstWhere(
      (p) => p.id == event.proposalId,
      orElse: () => current.proposals.first,
    );
    final order = OrderModel(
      id: current.orderId,
      serviceType: proposal.provider.categoryName,
      description: 'Rejalashtirilgan buyurtma',
      address: 'Yunusobod, Toshkent',
      status: OrderStatus.providerSelected,
      type: OrderType.scheduled,
      createdAt: DateTime.now(),
      provider: proposal.provider,
      estimatedPrice: proposal.price,
    );
    emit(ScheduledOrderConfirmed(order));
  }
}
