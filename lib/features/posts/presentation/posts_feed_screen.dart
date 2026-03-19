import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart' show Share;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../../../core/models/post_model.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';

class PostsFeedScreen extends StatefulWidget {
  const PostsFeedScreen({super.key});

  @override
  State<PostsFeedScreen> createState() => _PostsFeedScreenState();
}

class _PostsFeedScreenState extends State<PostsFeedScreen> {
  final _searchCtrl = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<PostsBloc>().add(const LoadAllPosts());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  Future<void> _startVoice() async {
    final ok = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (ok) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'uz_UZ',
        onResult: (r) {
          if (r.finalResult) {
            setState(() {
              _query = r.recognizedWords;
              _searchCtrl.text = r.recognizedWords;
              _isListening = false;
            });
          }
        },
      );
    }
  }

  void _stopVoice() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  List<PostModel> _filtered(List<PostModel> posts) {
    if (_query.trim().isEmpty) return posts;
    final q = _query.toLowerCase();
    return posts.where((p) {
      return p.providerName.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF8F9FB);
    final surf = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surf,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Portfolio',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Search bar with voice
          _buildSearchBar(isDark),
          // Feed
          Expanded(
            child: BlocBuilder<PostsBloc, PostsState>(
              builder: (context, state) {
                if (state is PostsLoading) {
                  return _buildShimmer(isDark);
                }
                if (state is PostsLoaded) {
                  final posts = _filtered(state.posts);
                  if (posts.isEmpty) {
                    return _buildEmpty(isDark);
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context.read<PostsBloc>().add(const LoadAllPosts());
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: posts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _PostCard(
                          post: posts[index],
                          timeAgo: _timeAgo(posts[index].createdAt),
                          isDark: isDark,
                          surf: surf,
                          onLike: () => context
                              .read<PostsBloc>()
                              .add(LikePost(posts[index].id)),
                          onProviderTap: () {},
                        );
                      },
                    ),
                  );
                }
                if (state is PostsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            _isListening ? Icons.graphic_eq_rounded : Icons.search_rounded,
            color: _isListening
                ? AppColors.error
                : (isDark ? AppColors.darkTextHint : AppColors.textHint),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: _isListening
                    ? 'Gapiring...'
                    : 'Usta, xizmat yoki kalit so\'z...',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 13,
                  color: _isListening
                      ? AppColors.error
                      : (isDark ? AppColors.darkTextHint : AppColors.textHint),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          GestureDetector(
            onTap: _isListening ? _stopVoice : _startVoice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isListening
                    ? AppColors.error.withValues(alpha: 0.15)
                    : (isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: _isListening ? AppColors.error : AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_view_outlined,
              size: 56,
              color: isDark ? AppColors.darkTextHint : AppColors.grey300),
          const SizedBox(height: 12),
          Text(
            'Hech narsa topilmadi',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 4,
      itemBuilder: (_, i) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.grey100,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                )),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Container(
                      height: 12,
                      width: double.infinity,
                      color:
                          isDark ? AppColors.darkSurface2 : AppColors.grey100),
                  const SizedBox(height: 8),
                  Container(
                      height: 12,
                      width: 200,
                      color:
                          isDark ? AppColors.darkSurface2 : AppColors.grey100),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Post Card ────────────────────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final PostModel post;
  final String timeAgo;
  final bool isDark;
  final Color surf;
  final VoidCallback onLike;
  final VoidCallback onProviderTap;

  const _PostCard({
    required this.post,
    required this.timeAgo,
    required this.isDark,
    required this.surf,
    required this.onLike,
    required this.onProviderTap,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _expanded = false;
  bool _followed = false;
  bool _showComments = false;
  final _commentCtrl = TextEditingController();

  // Dummy comments
  final List<Map<String, String>> _comments = [
    {'user': 'Sardor T.', 'text': 'Juda zo\'r ish!', 'time': '2s oldin'},
    {'user': 'Malika Y.', 'text': 'Professional yondashuv 👍', 'time': '5s oldin'},
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: widget.surf,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onProviderTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: post.providerAvatar,
                        fit: BoxFit.cover,
                        placeholder: (_, _) =>
                            Container(color: AppColors.primaryLight),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.primaryLight,
                          child: Center(
                            child: Text(
                              post.providerName.isNotEmpty
                                  ? post.providerName[0]
                                  : 'U',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: widget.onProviderTap,
                        child: Text(
                          post.providerName,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkPrimaryLight
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              post.categoryName,
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '• ${widget.timeAgo}',
                            style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _followed = !_followed),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _followed
                          ? AppColors.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: _followed
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _followed ? 'Kuzatilmoqda' : 'Kuzatish',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _followed
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Images
          if (post.images.isNotEmpty) _buildImages(post, isDark),

          // Description
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.description,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      height: 1.45,
                    ),
                    maxLines: _expanded ? null : 2,
                    overflow: _expanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (!_expanded && post.description.length > 80)
                    Text(
                      'Ko\'proq ko\'rish',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Actions row
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                _ActionBtn(
                  icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '${post.likes}',
                  color:
                      post.isLiked ? Colors.red : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  onTap: widget.onLike,
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${_comments.length}',
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  onTap: () =>
                      setState(() => _showComments = !_showComments),
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.share_outlined,
                  label: 'Ulashish',
                  color:
                      isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  onTap: () => Share.share(
                    '${post.providerName} - ${post.categoryName}\n${post.description}',
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface2
                        : AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payments_outlined,
                          size: 13, color: AppColors.orange),
                      const SizedBox(width: 4),
                      Text(
                        post.priceRange,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Comments section
          if (_showComments) _buildComments(isDark),
        ],
      ),
    );
  }

  Widget _buildImages(PostModel post, bool isDark) {
    if (post.images.length == 1) {
      return GestureDetector(
        onTap: () => _openViewer(context, post.images, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: CachedNetworkImage(
            imageUrl: post.images.first,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
                height: 220,
                color: isDark ? AppColors.darkSurface2 : AppColors.grey100),
            errorWidget: (_, _, _) => Container(
                height: 220,
                color: isDark ? AppColors.darkSurface2 : AppColors.grey100),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openViewer(context, post.images, 0),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: post.images.first,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
                height: 220,
                color: isDark ? AppColors.darkSurface2 : AppColors.grey100),
            errorWidget: (_, _, _) => Container(
                height: 220,
                color: isDark ? AppColors.darkSurface2 : AppColors.grey100),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 13, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '${post.images.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComments(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._comments.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          c['user']![0],
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                c['user']!,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                c['time']!,
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: isDark
                                      ? AppColors.darkTextHint
                                      : AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            c['text']!,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Izoh yozing...',
                    hintStyle: GoogleFonts.nunito(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextHint
                            : AppColors.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    isDense: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_commentCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _comments.add({
                        'user': 'Siz',
                        'text': _commentCtrl.text.trim(),
                        'time': 'Hozirgina',
                      });
                      _commentCtrl.clear();
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.send_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openViewer(BuildContext context, List<String> images, int initial) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ImageViewer(images: images, initial: initial),
    ));
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatefulWidget {
  final List<String> images;
  final int initial;

  const _ImageViewer({required this.images, required this.initial});

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late int _current;
  late PageController _page;

  @override
  void initState() {
    super.initState();
    _current = widget.initial;
    _page = PageController(initialPage: widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.images.length}',
          style: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
        ),
      ),
      body: PageView.builder(
        controller: _page,
        itemCount: widget.images.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => Center(
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: widget.images[i],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
