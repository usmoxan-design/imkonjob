import 'package:equatable/equatable.dart';

abstract class ProvidersEvent extends Equatable {
  const ProvidersEvent();

  @override
  List<Object?> get props => [];
}

class LoadProviders extends ProvidersEvent {
  const LoadProviders();
}

class FilterProviders extends ProvidersEvent {
  final String? categoryId;
  final double? maxDistance;
  final double? minRating;

  const FilterProviders({this.categoryId, this.maxDistance, this.minRating});

  @override
  List<Object?> get props => [categoryId, maxDistance, minRating];
}

class SearchProvidersByQuery extends ProvidersEvent {
  final String query;
  const SearchProvidersByQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearFilters extends ProvidersEvent {
  const ClearFilters();
}
