import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<SwitchToProviderMode>(_onSwitchToProviderMode);
    on<LogoutProfile>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(AppConstants.userNameKey) ?? 'Foydalanuvchi';
      final phone = prefs.getString(AppConstants.userPhoneKey) ?? '+998901234567';
      final id = prefs.getString(AppConstants.userIdKey) ?? '1';
      final isProvider = prefs.getBool(AppConstants.isProviderKey) ?? false;
      emit(ProfileLoaded(UserModel(
        id: id,
        name: name,
        phone: phone,
        isProvider: isProvider,
        isVerified: false,
      )));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    emit(const ProfileLoading());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userNameKey, event.name);
    emit(ProfileLoaded(current.user.copyWith(name: event.name)));
  }

  Future<void> _onSwitchToProviderMode(
    SwitchToProviderMode event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.isProviderKey, true);
    emit(ProfileLoaded(current.user.copyWith(isProvider: true)));
  }

  Future<void> _onLogout(
    LogoutProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(const ProfileInitial());
  }
}
