import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/mock/mock_data.dart';
import 'providers_event.dart';
import 'providers_state.dart';

class ProvidersBloc extends Bloc<ProvidersEvent, ProvidersState> {
  ProvidersBloc() : super(const ProvidersInitial()) {
    on<LoadProviders>(_onLoadProviders);
    on<FilterProviders>(_onFilterProviders);
    on<SearchProvidersByQuery>(_onSearch);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadProviders(
    LoadProviders event,
    Emitter<ProvidersState> emit,
  ) async {
    emit(const ProvidersLoading());
    await Future.delayed(const Duration(milliseconds: 700));
    final all = MockData.providers;
    emit(ProvidersLoaded(providers: all, allProviders: all));
  }

  void _onFilterProviders(
    FilterProviders event,
    Emitter<ProvidersState> emit,
  ) {
    if (state is! ProvidersLoaded) return;
    final current = state as ProvidersLoaded;
    var filtered = current.allProviders;

    if (event.categoryId != null) {
      if (event.categoryId == current.selectedCategoryId) {
        emit(current.copyWith(
          providers: current.allProviders,
          selectedCategoryId: null,
        ));
        return;
      }
      filtered = filtered.where((p) => p.categoryId == event.categoryId).toList();
    }
    if (event.maxDistance != null) {
      filtered = filtered.where((p) => p.distance <= event.maxDistance!).toList();
    }
    if (event.minRating != null) {
      filtered = filtered.where((p) => p.rating >= event.minRating!).toList();
    }

    emit(current.copyWith(
      providers: filtered,
      selectedCategoryId: event.categoryId,
    ));
  }

  void _onSearch(
    SearchProvidersByQuery event,
    Emitter<ProvidersState> emit,
  ) {
    if (state is! ProvidersLoaded) return;
    final current = state as ProvidersLoaded;
    final q = event.query.toLowerCase();
    final filtered = current.allProviders
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q))
        .toList();
    emit(current.copyWith(providers: filtered, searchQuery: event.query));
  }

  void _onClearFilters(ClearFilters event, Emitter<ProvidersState> emit) {
    if (state is! ProvidersLoaded) return;
    final current = state as ProvidersLoaded;
    emit(current.copyWith(
      providers: current.allProviders,
      selectedCategoryId: null,
      searchQuery: null,
    ));
  }
}
