import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/post_model.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';

class ProviderPostsTab extends StatefulWidget {
  final String providerId;

  const ProviderPostsTab({super.key, required this.providerId});

  @override
  State<ProviderPostsTab> createState() => _ProviderPostsTabState();
}

class _ProviderPostsTabState extends State<ProviderPostsTab> {
  @override
  void initState() {
    super.initState();
    context
        .read<PostsBloc>()
        .add(LoadProviderPosts(widget.providerId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        if (state is PostsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PostsLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 56, color: AppColors.grey400),
                    const SizedBox(height: 12),
                    Text(
                      'Hozircha ishlar yo\'q',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              return _PostThumbnail(post: state.posts[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _PostThumbnail extends StatelessWidget {
  final PostModel post;

  const _PostThumbnail({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPostDetail(context, post),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: post.images.isNotEmpty
                  ? post.images.first
                  : 'https://picsum.photos/seed/${post.id}/400/400',
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(color: AppColors.grey200),
              errorWidget: (_, _, _) =>
                  Container(color: AppColors.grey200),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.favorite,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      '${post.likes}',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetail(BuildContext context, PostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (post.images.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: post.images.first,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      Container(height: 240, color: AppColors.grey200),
                  errorWidget: (_, _, _) =>
                      Container(height: 240, color: AppColors.grey200),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.categoryName,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.description,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            size: 16, color: AppColors.orange),
                        const SizedBox(width: 6),
                        Text(
                          post.priceRange,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
