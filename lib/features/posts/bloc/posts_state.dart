import 'package:equatable/equatable.dart';
import '../../../core/models/post_model.dart';

abstract class PostsState extends Equatable {
  const PostsState();
  @override
  List<Object?> get props => [];
}

class PostsInitial extends PostsState {
  const PostsInitial();
}

class PostsLoading extends PostsState {
  const PostsLoading();
}

class PostsLoaded extends PostsState {
  final List<PostModel> posts;
  const PostsLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class PostsError extends PostsState {
  final String message;
  const PostsError(this.message);
  @override
  List<Object?> get props => [message];
}

class PostCreating extends PostsState {
  const PostCreating();
}

class PostCreated extends PostsState {
  const PostCreated();
}
