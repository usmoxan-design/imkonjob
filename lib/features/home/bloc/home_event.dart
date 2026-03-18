import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

class SearchProviders extends HomeEvent {
  final String query;
  const SearchProviders(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByCategory extends HomeEvent {
  final String categoryId;
  const FilterByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
