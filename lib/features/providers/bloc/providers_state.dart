import 'package:equatable/equatable.dart';
import '../../../core/models/provider_model.dart';

abstract class ProvidersState extends Equatable {
  const ProvidersState();

  @override
  List<Object?> get props => [];
}

class ProvidersInitial extends ProvidersState {
  const ProvidersInitial();
}

class ProvidersLoading extends ProvidersState {
  const ProvidersLoading();
}

class ProvidersLoaded extends ProvidersState {
  final List<ProviderModel> providers;
  final List<ProviderModel> allProviders;
  final String? selectedCategoryId;
  final String? searchQuery;

  const ProvidersLoaded({
    required this.providers,
    required this.allProviders,
    this.selectedCategoryId,
    this.searchQuery,
  });

  ProvidersLoaded copyWith({
    List<ProviderModel>? providers,
    List<ProviderModel>? allProviders,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return ProvidersLoaded(
      providers: providers ?? this.providers,
      allProviders: allProviders ?? this.allProviders,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [providers, allProviders, selectedCategoryId, searchQuery];
}

class ProvidersError extends ProvidersState {
  final String message;
  const ProvidersError(this.message);

  @override
  List<Object?> get props => [message];
}
