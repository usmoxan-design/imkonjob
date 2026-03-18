import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

class PhoneSubmitted extends AuthEvent {
  final String phone;
  const PhoneSubmitted(this.phone);

  @override
  List<Object?> get props => [phone];
}

class OtpSubmitted extends AuthEvent {
  final String otp;
  const OtpSubmitted(this.otp);

  @override
  List<Object?> get props => [otp];
}

class ProfileSetupSubmitted extends AuthEvent {
  final String name;
  final UserType userType;
  const ProfileSetupSubmitted({required this.name, required this.userType});

  @override
  List<Object?> get props => [name, userType];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class TelegramSignInCompleted extends AuthEvent {
  final Map<String, dynamic> telegramUser;
  const TelegramSignInCompleted({required this.telegramUser});

  @override
  List<Object?> get props => [telegramUser];
}

class GuestContinue extends AuthEvent {
  const GuestContinue();
}
