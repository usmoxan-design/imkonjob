import 'package:equatable/equatable.dart';

enum UserType { client, worker }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final bool isProvider;
  final bool isVerified;
  final UserType userType;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.isProvider = false,
    this.isVerified = false,
    this.userType = UserType.client,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    bool? isProvider,
    bool? isVerified,
    UserType? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isProvider: isProvider ?? this.isProvider,
      isVerified: isVerified ?? this.isVerified,
      userType: userType ?? this.userType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'isProvider': isProvider,
      'isVerified': isVerified,
      'userType': userType.name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      avatar: map['avatar'],
      isProvider: map['isProvider'] ?? false,
      isVerified: map['isVerified'] ?? false,
      userType: UserType.values.firstWhere(
        (e) => e.name == (map['userType'] ?? 'client'),
        orElse: () => UserType.client,
      ),
    );
  }

  @override
  List<Object?> get props => [id, name, phone, avatar, isProvider, isVerified, userType];
}
