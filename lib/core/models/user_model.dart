import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final bool isProvider;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.isProvider = false,
    this.isVerified = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatar,
    bool? isProvider,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      isProvider: isProvider ?? this.isProvider,
      isVerified: isVerified ?? this.isVerified,
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
    );
  }

  @override
  List<Object?> get props => [id, name, phone, avatar, isProvider, isVerified];
}
