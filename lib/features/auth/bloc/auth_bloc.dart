import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  String? _pendingPhone;

  AuthBloc() : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<PhoneSubmitted>(_onPhoneSubmitted);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<ProfileSetupSubmitted>(_onProfileSetupSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<TelegramSignInCompleted>(_onTelegramSignInCompleted);
    on<GuestContinue>(_onGuestContinue);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(AppConstants.userNameKey);
      final phone = prefs.getString(AppConstants.userPhoneKey);
      final id = prefs.getString(AppConstants.userIdKey);
      if (name != null && phone != null && id != null) {
        final userTypeStr = prefs.getString(AppConstants.userTypeKey) ?? 'client';
        final userType = UserType.values.firstWhere(
          (e) => e.name == userTypeStr,
          orElse: () => UserType.client,
        );
        final user = UserModel(
          id: id,
          name: name,
          phone: phone,
          avatar: prefs.getString('user_avatar'),
          isProvider: prefs.getBool(AppConstants.isProviderKey) ?? false,
          userType: userType,
        );
        emit(AuthAuthenticated(user));
      } else if (prefs.getBool(AppConstants.isGuestKey) == true) {
        emit(const AuthGuest());
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onPhoneSubmitted(PhoneSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1500));
    _pendingPhone = event.phone;
    emit(PhoneSubmitSuccess(event.phone));
  }

  Future<void> _onOtpSubmitted(OtpSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    if (event.otp == AppConstants.testOtp) {
      emit(OtpVerifySuccess(_pendingPhone ?? ''));
    } else {
      emit(const AuthError('Noto\'g\'ri kod. Test uchun: 1234'));
    }
  }

  Future<void> _onProfileSetupSubmitted(ProfileSetupSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final prefs = await SharedPreferences.getInstance();
      const uuid = Uuid();
      final id = prefs.getString(AppConstants.userIdKey) ?? uuid.v4();
      final phone = _pendingPhone ?? prefs.getString(AppConstants.userPhoneKey) ?? '';
      await prefs.setString(AppConstants.userNameKey, event.name);
      await prefs.setString(AppConstants.userPhoneKey, phone);
      await prefs.setString(AppConstants.userIdKey, id);
      await prefs.setBool(AppConstants.isProviderKey, false);
      await prefs.setString(AppConstants.userTypeKey, event.userType.name);
      emit(AuthAuthenticated(UserModel(
        id: id,
        name: event.name,
        phone: phone,
        avatar: prefs.getString('user_avatar'),
        userType: event.userType,
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userNameKey);
      await prefs.remove(AppConstants.userPhoneKey);
      await prefs.remove(AppConstants.userIdKey);
      await prefs.remove(AppConstants.isProviderKey);
      await prefs.remove(AppConstants.isGuestKey);
      await prefs.remove(AppConstants.userTypeKey);
      await prefs.remove('user_avatar');
      _pendingPhone = null;
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onTelegramSignInCompleted(TelegramSignInCompleted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final firstName = event.telegramUser['first_name'] as String? ?? '';
      final lastName = event.telegramUser['last_name'] as String? ?? '';
      final photoUrl = event.telegramUser['photo_url'] as String?;
      final telegramId = event.telegramUser['id']?.toString() ?? '';

      final prefs = await SharedPreferences.getInstance();
      final uuid = const Uuid();
      final id = uuid.v4();
      await prefs.setString(AppConstants.userIdKey, id);
      await prefs.setString(AppConstants.userPhoneKey, 'tg:$telegramId');
      if (photoUrl != null) await prefs.setString('user_avatar', photoUrl);

      emit(NeedsProfileSetup(
        prefilledName: '$firstName $lastName'.trim().isNotEmpty
            ? '$firstName $lastName'.trim()
            : null,
        prefilledAvatar: photoUrl,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGuestContinue(GuestContinue event, Emitter<AuthState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.isGuestKey, true);
      emit(const AuthGuest());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
