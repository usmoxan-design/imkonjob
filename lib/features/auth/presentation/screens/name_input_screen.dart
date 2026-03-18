import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

class NameInputScreen extends StatefulWidget {
  final String? prefilledName;
  final String? prefilledAvatar;

  const NameInputScreen({
    super.key,
    this.prefilledName,
    this.prefilledAvatar,
  });

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefilledName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(ProfileSetupSubmitted(
        name: _nameController.text.trim(),
        userType: UserType.client,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 28),
                  Text(
                    'Ismingizni kiriting',
                    style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bu sizni boshqalar ko\'radigan ism',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  CustomTextField(
                    controller: _nameController,
                    hint: 'Ism va Familiya',
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Kamida 2 ta harf kiriting';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        label: 'Boshlash',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                        suffixIcon: Icons.arrow_forward_rounded,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (widget.prefilledAvatar != null) {
      return CircleAvatar(
        radius: 48,
        backgroundColor: AppColors.muted,
        backgroundImage: CachedNetworkImageProvider(widget.prefilledAvatar!),
      );
    }
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded, size: 52, color: AppColors.primary),
    );
  }
}
