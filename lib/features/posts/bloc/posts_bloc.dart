import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/post_model.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc() : super(const PostsInitial()) {
    on<LoadAllPosts>(_onLoadAll);
    on<LoadProviderPosts>(_onLoadProvider);
    on<LikePost>(_onLike);
    on<CreatePost>(_onCreate);
    on<DeletePost>(_onDelete);
  }

  Future<void> _onLoadAll(
    LoadAllPosts event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(PostsLoaded(List<PostModel>.from(MockData.posts)));
  }

  Future<void> _onLoadProvider(
    LoadProviderPosts event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(PostsLoaded(MockData.getProviderPosts(event.providerId)));
  }

  void _onLike(LikePost event, Emitter<PostsState> emit) {
    if (state is! PostsLoaded) return;
    final current = (state as PostsLoaded).posts;
    final updated = current.map((post) {
      if (post.id == event.postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        );
      }
      return post;
    }).toList();
    emit(PostsLoaded(updated));
  }

  Future<void> _onCreate(
    CreatePost event,
    Emitter<PostsState> emit,
  ) async {
    final previousPosts =
        state is PostsLoaded ? (state as PostsLoaded).posts : <PostModel>[];
    emit(const PostCreating());
    await Future.delayed(const Duration(seconds: 1));

    const uuid = Uuid();
    final newPost = PostModel(
      id: uuid.v4(),
      providerId: '1',
      providerName: 'Jasur Toshmatov',
      providerAvatar: 'https://i.pravatar.cc/150?img=1',
      description: event.description,
      images: ['https://picsum.photos/seed/${uuid.v4()}/600/400'],
      createdAt: DateTime.now(),
      likes: 0,
      isLiked: false,
      categoryName: event.categoryName,
      priceRange: event.priceRange,
    );

    emit(const PostCreated());
    final updatedPosts = [newPost, ...previousPosts];
    emit(PostsLoaded(updatedPosts));
  }

  void _onDelete(DeletePost event, Emitter<PostsState> emit) {
    if (state is! PostsLoaded) return;
    final current = (state as PostsLoaded).posts;
    final updated = current.where((p) => p.id != event.postId).toList();
    emit(PostsLoaded(updated));
  }
}
