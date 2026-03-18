import 'package:equatable/equatable.dart';

class ProviderModel extends Equatable {
  final String id;
  final String name;
  final String avatar;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final bool isOnline;
  final String categoryId;
  final String categoryName;
  final String location;
  final double distance;
  final String priceRange;
  final List<String> portfolio;
  final String bio;
  final int completedOrders;
  final String workingHours;
  final bool hasTransport;
  final bool acceptsQuickOrders;

  const ProviderModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.isOnline,
    required this.categoryId,
    required this.categoryName,
    required this.location,
    required this.distance,
    required this.priceRange,
    required this.portfolio,
    required this.bio,
    required this.completedOrders,
    required this.workingHours,
    required this.hasTransport,
    required this.acceptsQuickOrders,
  });

  ProviderModel copyWith({
    String? id,
    String? name,
    String? avatar,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    bool? isOnline,
    String? categoryId,
    String? categoryName,
    String? location,
    double? distance,
    String? priceRange,
    List<String>? portfolio,
    String? bio,
    int? completedOrders,
    String? workingHours,
    bool? hasTransport,
    bool? acceptsQuickOrders,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      priceRange: priceRange ?? this.priceRange,
      portfolio: portfolio ?? this.portfolio,
      bio: bio ?? this.bio,
      completedOrders: completedOrders ?? this.completedOrders,
      workingHours: workingHours ?? this.workingHours,
      hasTransport: hasTransport ?? this.hasTransport,
      acceptsQuickOrders: acceptsQuickOrders ?? this.acceptsQuickOrders,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatar,
        rating,
        reviewCount,
        isVerified,
        isOnline,
        categoryId,
        categoryName,
        location,
        distance,
        priceRange,
        portfolio,
        bio,
        completedOrders,
        workingHours,
        hasTransport,
        acceptsQuickOrders,
      ];
}
