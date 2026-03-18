import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfile extends ProfileEvent {
  final String name;
  const UpdateProfile(this.name);

  @override
  List<Object?> get props => [name];
}

class SwitchToProviderMode extends ProfileEvent {
  const SwitchToProviderMode();
}

class LogoutProfile extends ProfileEvent {
  const LogoutProfile();
}
