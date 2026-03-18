import 'package:equatable/equatable.dart';

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

class NameSubmitted extends AuthEvent {
  final String name;
  const NameSubmitted(this.name);

  @override
  List<Object?> get props => [name];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
