import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/provider_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<SearchProviders>(_onSearchProviders);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    final providers = MockData.providers;
    final suggested = providers.where((p) => p.isVerified && p.rating >= 4.6).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final nearby = providers.where((p) => p.distance <= 5.0).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
    emit(HomeLoaded(
      categories: MockData.categories,
      suggestedProviders: suggested.take(8).toList(),
      nearbyProviders: nearby.take(8).toList(),
    ));
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final providers = MockData.providers;
    final suggested = providers.where((p) => p.isVerified && p.rating >= 4.6).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final nearby = providers.where((p) => p.distance <= 5.0).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
    emit(HomeLoaded(
      categories: MockData.categories,
      suggestedProviders: suggested.take(8).toList(),
      nearbyProviders: nearby.take(8).toList(),
    ));
  }

  Future<void> _onSearchProviders(
    SearchProviders event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    final query = event.query.toLowerCase();
    final List<ProviderModel> filtered = MockData.providers
        .where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.categoryName.toLowerCase().contains(query))
        .toList();
    emit(current.copyWith(suggestedProviders: filtered));
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;
    if (event.categoryId == current.selectedCategoryId) {
      final providers = MockData.providers;
      final suggested = providers.where((p) => p.isVerified && p.rating >= 4.6).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      emit(current.copyWith(
        suggestedProviders: suggested.take(8).toList(),
        selectedCategoryId: null,
      ));
    } else {
      final filtered = MockData.providers
          .where((p) => p.categoryId == event.categoryId)
          .toList();
      emit(current.copyWith(
        suggestedProviders: filtered,
        selectedCategoryId: event.categoryId,
      ));
    }
  }
}
