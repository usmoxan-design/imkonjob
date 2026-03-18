import 'package:equatable/equatable.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/provider_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<ProviderModel> suggestedProviders;
  final List<ProviderModel> nearbyProviders;
  final String? selectedCategoryId;

  const HomeLoaded({
    required this.categories,
    required this.suggestedProviders,
    required this.nearbyProviders,
    this.selectedCategoryId,
  });

  HomeLoaded copyWith({
    List<CategoryModel>? categories,
    List<ProviderModel>? suggestedProviders,
    List<ProviderModel>? nearbyProviders,
    String? selectedCategoryId,
  }) {
    return HomeLoaded(
      categories: categories ?? this.categories,
      suggestedProviders: suggestedProviders ?? this.suggestedProviders,
      nearbyProviders: nearbyProviders ?? this.nearbyProviders,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        suggestedProviders,
        nearbyProviders,
        selectedCategoryId,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
