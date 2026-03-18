import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class PhoneSubmitSuccess extends AuthState {
  final String phone;
  const PhoneSubmitSuccess(this.phone);

  @override
  List<Object?> get props => [phone];
}

class OtpVerifySuccess extends AuthState {
  final String phone;
  const OtpVerifySuccess(this.phone);

  @override
  List<Object?> get props => [phone];
}

class NeedsProfileSetup extends AuthState {
  final String? prefilledName;
  final String? prefilledAvatar;

  const NeedsProfileSetup({this.prefilledName, this.prefilledAvatar});

  @override
  List<Object?> get props => [prefilledName, prefilledAvatar];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class GoogleSignInLoading extends AuthState {
  const GoogleSignInLoading();
}

class AuthGuest extends AuthState {
  const AuthGuest();
}
