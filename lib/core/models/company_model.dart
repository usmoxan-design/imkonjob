import 'package:equatable/equatable.dart';

class CompanyModel extends Equatable {
  final String id;
  final String name;
  final String logo;
  final String description;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final List<String> serviceCategories;
  final String location;
  final String phone;
  final String workingHours;
  final int completedOrders;
  final String priceRange;
  final List<String> portfolio;

  const CompanyModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.description,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
    required this.serviceCategories,
    required this.location,
    required this.phone,
    required this.workingHours,
    required this.completedOrders,
    required this.priceRange,
    required this.portfolio,
  });

  CompanyModel copyWith({
    String? id,
    String? name,
    String? logo,
    String? description,
    bool? isVerified,
    double? rating,
    int? reviewCount,
    List<String>? serviceCategories,
    String? location,
    String? phone,
    String? workingHours,
    int? completedOrders,
    String? priceRange,
    List<String>? portfolio,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      workingHours: workingHours ?? this.workingHours,
      completedOrders: completedOrders ?? this.completedOrders,
      priceRange: priceRange ?? this.priceRange,
      portfolio: portfolio ?? this.portfolio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        logo,
        description,
        isVerified,
        rating,
        reviewCount,
        serviceCategories,
        location,
        phone,
        workingHours,
        completedOrders,
        priceRange,
        portfolio,
      ];
}
