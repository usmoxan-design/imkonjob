import 'package:flutter_bloc/flutter_bloc.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(const ReviewInitial()) {
    on<SubmitReview>(_onSubmitReview);
    on<SubmitComplaint>(_onSubmitComplaint);
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewSubmitting());
    await Future.delayed(const Duration(milliseconds: 1500));
    emit(const ReviewSubmitted());
  }

  Future<void> _onSubmitComplaint(
    SubmitComplaint event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ComplaintSubmitting());
    await Future.delayed(const Duration(milliseconds: 1500));
    emit(const ComplaintSubmitted());
  }
}
