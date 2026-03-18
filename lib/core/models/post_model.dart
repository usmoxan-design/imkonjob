import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String providerId;
  final String providerName;
  final String providerAvatar;
  final String description;
  final List<String> images;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final String categoryName;
  final String priceRange;

  const PostModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerAvatar,
    required this.description,
    required this.images,
    required this.createdAt,
    required this.likes,
    required this.isLiked,
    required this.categoryName,
    required this.priceRange,
  });

  PostModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerAvatar,
    String? description,
    List<String>? images,
    DateTime? createdAt,
    int? likes,
    bool? isLiked,
    String? categoryName,
    String? priceRange,
  }) {
    return PostModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerAvatar: providerAvatar ?? this.providerAvatar,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      categoryName: categoryName ?? this.categoryName,
      priceRange: priceRange ?? this.priceRange,
    );
  }

  @override
  List<Object?> get props => [
        id,
        providerId,
        providerName,
        providerAvatar,
        description,
        images,
        createdAt,
        likes,
        isLiked,
        categoryName,
        priceRange,
      ];
}
