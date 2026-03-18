import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tavsif kiriting',
              style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<PostsBloc>().add(CreatePost(
          description: _descController.text.trim(),
          categoryName: _selectedCategory ?? 'Boshqa',
          priceRange: _priceController.text.trim().isEmpty
              ? 'Narx kelishiladi'
              : _priceController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostsBloc, PostsState>(
      listener: (context, state) {
        if (state is PostCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Post muvaffaqiyatli nashr qilindi!',
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
          title: Text('Post qo\'shish',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Rasm tanlash imkoni keyingi versiyada',
                                style:
                                    GoogleFonts.nunito(color: Colors.white)),
                            backgroundColor: AppColors.textSecondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 28, color: AppColors.grey500),
                            const SizedBox(height: 4),
                            Text(
                              index == 0 ? 'Asosiy' : 'Qo\'shimcha',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Text('Tavsif',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descController,
                hint: 'Bajargan ishingizni tasvirlab bering...',
                maxLines: 5,
                minLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              Text('Kategoriya',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: Text('Kategoriya tanlang',
                        style: GoogleFonts.nunito(
                            fontSize: 14, color: AppColors.textSecondary)),
                    items: MockData.categories
                        .map((c) => DropdownMenuItem(
                              value: c.name,
                              child: Text('${c.icon}  ${c.name}',
                                  style: GoogleFonts.nunito(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Narx diapazoni',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _priceController,
                hint: 'Masalan: 200,000 so\'m',
                prefixIcon: const Icon(Icons.payments_outlined,
                    color: AppColors.textSecondary),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 32),
              BlocBuilder<PostsBloc, PostsState>(
                builder: (context, state) {
                  return CustomButton(
                    label: 'Nashr qilish',
                    prefixIcon: Icons.publish_rounded,
                    isLoading: state is PostCreating,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
