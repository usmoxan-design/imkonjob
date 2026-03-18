import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllPosts extends PostsEvent {
  const LoadAllPosts();
}

class LoadProviderPosts extends PostsEvent {
  final String providerId;
  const LoadProviderPosts(this.providerId);
  @override
  List<Object?> get props => [providerId];
}

class LikePost extends PostsEvent {
  final String postId;
  const LikePost(this.postId);
  @override
  List<Object?> get props => [postId];
}

class CreatePost extends PostsEvent {
  final String description;
  final String categoryName;
  final String priceRange;
  const CreatePost({
    required this.description,
    required this.categoryName,
    required this.priceRange,
  });
  @override
  List<Object?> get props => [description, categoryName, priceRange];
}

class DeletePost extends PostsEvent {
  final String postId;
  const DeletePost(this.postId);
  @override
  List<Object?> get props => [postId];
}
