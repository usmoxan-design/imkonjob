import 'package:equatable/equatable.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewSubmitting extends ReviewState {
  const ReviewSubmitting();
}

class ReviewSubmitted extends ReviewState {
  const ReviewSubmitted();
}

class ComplaintSubmitting extends ReviewState {
  const ComplaintSubmitting();
}

class ComplaintSubmitted extends ReviewState {
  const ComplaintSubmitted();
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}
