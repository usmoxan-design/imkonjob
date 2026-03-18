import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class SubmitReview extends ReviewEvent {
  final String orderId;
  final String providerId;
  final double rating;
  final String comment;
  final List<String> tags;

  const SubmitReview({
    required this.orderId,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.tags,
  });

  @override
  List<Object?> get props => [orderId, providerId, rating, comment, tags];
}

class SubmitComplaint extends ReviewEvent {
  final String orderId;
  final String providerId;
  final String type;
  final String description;

  const SubmitComplaint({
    required this.orderId,
    required this.providerId,
    required this.type,
    required this.description,
  });

  @override
  List<Object?> get props => [orderId, providerId, type, description];
}
