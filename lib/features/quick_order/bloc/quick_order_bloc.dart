import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/order_model.dart';
import 'quick_order_event.dart';
import 'quick_order_state.dart';

class QuickOrderBloc extends Bloc<QuickOrderEvent, QuickOrderState> {
  QuickOrderBloc() : super(const QuickOrderInitial()) {
    on<StartQuickOrder>(_onStart);
    on<SubmitQuickOrder>(_onSubmit);
    on<SelectProposal>(_onSelectProposal);
    on<CancelSearch>(_onCancelSearch);
  }

  void _onStart(StartQuickOrder event, Emitter<QuickOrderState> emit) {
    emit(const QuickOrderInitial());
  }

  Future<void> _onSubmit(
    SubmitQuickOrder event,
    Emitter<QuickOrderState> emit,
  ) async {
    emit(const QuickOrderSubmitting());
    await Future.delayed(const Duration(seconds: 1));

    const uuid = Uuid();
    final orderId = uuid.v4();
    emit(QuickOrderSearching(orderId));

    await Future.delayed(const Duration(seconds: 3));
    final proposals = MockData.getMockProposals(orderId);
    emit(QuickOrderProposalsReceived(proposals: proposals, orderId: orderId));
  }

  Future<void> _onSelectProposal(
    SelectProposal event,
    Emitter<QuickOrderState> emit,
  ) async {
    if (state is! QuickOrderProposalsReceived) return;
    final current = state as QuickOrderProposalsReceived;

    final proposal = current.proposals.firstWhere(
      (p) => p.id == event.proposalId,
      orElse: () => current.proposals.first,
    );

    final order = OrderModel(
      id: current.orderId,
      serviceType: proposal.provider.categoryName,
      description: 'Tezkor buyurtma',
      address: 'Yunusobod, Toshkent',
      status: OrderStatus.providerSelected,
      type: OrderType.quick,
      createdAt: DateTime.now(),
      provider: proposal.provider,
      estimatedPrice: proposal.price,
      estimatedArrival: proposal.estimatedArrival,
    );
    emit(QuickOrderConfirmed(order));
  }

  void _onCancelSearch(CancelSearch event, Emitter<QuickOrderState> emit) {
    emit(const QuickOrderInitial());
  }
}
