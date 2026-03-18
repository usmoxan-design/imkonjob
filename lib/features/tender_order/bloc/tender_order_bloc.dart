import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/order_model.dart';
import 'tender_order_event.dart';
import 'tender_order_state.dart';

class TenderOrderBloc extends Bloc<TenderOrderEvent, TenderOrderState> {
  TenderOrderBloc() : super(const TenderOrderInitial()) {
    on<SubmitTenderOrder>(_onSubmit);
    on<SelectTenderProposal>(_onSelectProposal);
    on<ResetTenderOrder>(_onReset);
  }

  Future<void> _onSubmit(
    SubmitTenderOrder event,
    Emitter<TenderOrderState> emit,
  ) async {
    emit(const TenderOrderSubmitting());
    await Future.delayed(const Duration(seconds: 1));

    const uuid = Uuid();
    final order = OrderModel(
      id: uuid.v4(),
      serviceType: event.serviceType,
      description: event.description,
      address: event.address,
      status: OrderStatus.searching,
      type: OrderType.tender,
      createdAt: DateTime.now(),
      proposals: [],
    );

    emit(TenderOrderSubmitted(order));
    await Future.delayed(const Duration(seconds: 2));

    final proposals = MockData.getMockProposals(order.id);
    emit(TenderProposalsReceived(proposals));
  }

  Future<void> _onSelectProposal(
    SelectTenderProposal event,
    Emitter<TenderOrderState> emit,
  ) async {
    emit(const TenderOrderConfirmed());
  }

  void _onReset(ResetTenderOrder event, Emitter<TenderOrderState> emit) {
    emit(const TenderOrderInitial());
  }
}
