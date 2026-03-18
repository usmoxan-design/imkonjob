import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_event.dart';
import '../bloc/review_state.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  final String providerId;
  final String providerName;
  final String providerAvatar;

  const ReviewScreen({
    super.key,
    required this.orderId,
    required this.providerId,
    required this.providerName,
    required this.providerAvatar,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 0;
  final Set<String> _selectedTags = {};
  final _commentController = TextEditingController();

  static const _tags = [
    'Vaqtida keldi',
    'Narx mos',
    'Ish sifatli',
    'Professionallik',
    'Muloqot yaxshi',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Iltimos, baho bering',
              style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<ReviewBloc>().add(SubmitReview(
          orderId: widget.orderId,
          providerId: widget.providerId,
          rating: _rating,
          comment: _commentController.text.trim(),
          tags: _selectedTags.toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bahoyingiz uchun rahmat!',
                  style: GoogleFonts.nunito(color: Colors.white)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Baholash',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.providerAvatar,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: AppColors.grey200),
                  errorWidget: (_, _, _) => Container(
                    color: AppColors.grey200,
                    child: const Icon(Icons.person, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.providerName,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Xizmat qanday bo\'ldi?',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Star rating selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = star.toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 48,
                        color: star <= _rating
                            ? AppColors.yellow
                            : AppColors.grey300,
                      ),
                    ),
                  );
                }),
              ),
              if (_rating > 0) ...[
                const SizedBox(height: 8),
                Text(
                  _ratingLabel(_rating),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.yellow,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Tags
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Nima yoqdi?',
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  final selected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        )),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Izoh (ixtiyoriy)',
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.nunito(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Usta haqida izoh qoldiring...',
                  hintStyle: GoogleFonts.nunito(
                      fontSize: 14, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<ReviewBloc, ReviewState>(
                builder: (context, state) => CustomButton(
                  label: 'Yuborish',
                  prefixIcon: Icons.send_rounded,
                  isLoading: state is ReviewSubmitting,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingLabel(double rating) {
    if (rating >= 5) return 'Ajoyib!';
    if (rating >= 4) return 'Yaxshi';
    if (rating >= 3) return 'O\'rtacha';
    if (rating >= 2) return 'Yomon';
    return 'Juda yomon';
  }
}
