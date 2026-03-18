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
    on<NameSubmitted>(_onNameSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(AppConstants.userNameKey);
      final phone = prefs.getString(AppConstants.userPhoneKey);
      final id = prefs.getString(AppConstants.userIdKey);
      if (name != null && phone != null && id != null) {
        final user = UserModel(
          id: id,
          name: name,
          phone: phone,
          isProvider: prefs.getBool(AppConstants.isProviderKey) ?? false,
        );
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onPhoneSubmitted(
    PhoneSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1500));
    _pendingPhone = event.phone;
    emit(PhoneSubmitSuccess(event.phone));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    if (event.otp == AppConstants.testOtp) {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString(AppConstants.userPhoneKey) ?? _pendingPhone ?? '';
      emit(OtpVerifySuccess(phone));
    } else {
      emit(const AuthError('Noto\'g\'ri kod. Test uchun: 1234'));
    }
  }

  Future<void> _onNameSubmitted(
    NameSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final prefs = await SharedPreferences.getInstance();
      const uuid = Uuid();
      final id = uuid.v4();
      final phone = _pendingPhone ?? '+998901234567';
      await prefs.setString(AppConstants.userNameKey, event.name);
      await prefs.setString(AppConstants.userPhoneKey, phone);
      await prefs.setString(AppConstants.userIdKey, id);
      await prefs.setBool(AppConstants.isProviderKey, false);
      final user = UserModel(id: id, name: event.name, phone: phone);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userNameKey);
      await prefs.remove(AppConstants.userPhoneKey);
      await prefs.remove(AppConstants.userIdKey);
      await prefs.remove(AppConstants.isProviderKey);
      _pendingPhone = null;
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
