import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/provider_mode_bloc.dart';
import '../bloc/provider_mode_event.dart';
import '../bloc/provider_mode_state.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _bioController = TextEditingController();
  final _locationController = TextEditingController(text: 'Yunusobod, Toshkent');
  final _workingHoursController =
      TextEditingController(text: '09:00 - 21:00');
  String? _selectedCategoryId;
  bool _hasTransport = false;

  @override
  void dispose() {
    _pageController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _submit() {
    context.read<ProviderModeBloc>().add(SubmitOnboarding(
          bio: _bioController.text,
          categoryId: _selectedCategoryId ?? 'plumbing',
          location: _locationController.text,
          workingHours: _workingHoursController.text,
          hasTransport: _hasTransport,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProviderModeBloc, ProviderModeState>(
      listener: (context, state) {
        if (state is ProviderModeActive || state is ProviderDashboardLoaded) {
          context.go('/provider/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Usta bo\'lib ishlash'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: _back,
          ),
        ),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentStep + 1}/5',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _getStepTitle(),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 5,
              backgroundColor: AppColors.grey200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    const titles = [
      'Shaxsiy ma\'lumotlar',
      'Kategoriya',
      'Ish hududi',
      'Ish vaqti',
      'Tasdiqlash',
    ];
    return titles[_currentStep];
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'O\'zingiz haqida yozing',
            style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Mijozlar sizni tanlashda bu ma\'lumot asosiy rol o\'ynaydi',
            style: GoogleFonts.nunito(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          CustomTextField(
            controller: _bioController,
            label: 'Bio',
            hint: 'Tajriba, ko\'nikmalar, kafolatlar haqida yozing...',
            maxLines: 5,
            minLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategoriya tanlang',
            style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Qaysi soha bo\'yicha xizmat ko\'rsatasiz?',
            style: GoogleFonts.nunito(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MockData.categories.map((cat) {
              final isSelected = _selectedCategoryId == cat.id;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedCategoryId = cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        cat.name,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ish hududi',
            style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Qaysi hududlarda xizmat ko\'rsatasiz?',
            style: GoogleFonts.nunito(
                fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          CustomTextField(
            controller: _locationController,
            label: 'Manzil',
            hint: 'Shahar, tuman',
            prefixIcon: const Icon(Icons.location_on_outlined,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ish vaqti',
            style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 28),
          CustomTextField(
            controller: _workingHoursController,
            label: 'Ish vaqti',
            hint: 'Masalan: 09:00 - 21:00',
            prefixIcon: const Icon(Icons.access_time_rounded,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car_rounded,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transportim bor',
                          style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Mijozga borishim mumkin',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: _hasTransport,
                  onChanged: (v) => setState(() => _hasTransport = v),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ma\'lumotlarni tasdiqlang',
            style: GoogleFonts.nunito(
                fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          _ReviewItem(
              icon: Icons.person_rounded,
              label: 'Bio',
              value: _bioController.text.isEmpty
                  ? 'Kiritilmagan'
                  : _bioController.text),
          _ReviewItem(
              icon: Icons.work_rounded,
              label: 'Kategoriya',
              value: _selectedCategoryId == null
                  ? 'Kiritilmagan'
                  : MockData.categories
                      .firstWhere((c) => c.id == _selectedCategoryId)
                      .name),
          _ReviewItem(
              icon: Icons.location_on_rounded,
              label: 'Joylashuv',
              value: _locationController.text),
          _ReviewItem(
              icon: Icons.access_time_rounded,
              label: 'Ish vaqti',
              value: _workingHoursController.text),
          _ReviewItem(
              icon: Icons.directions_car_rounded,
              label: 'Transport',
              value: _hasTransport ? 'Mavjud' : 'Yo\'q'),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BlocBuilder<ProviderModeBloc, ProviderModeState>(
        builder: (context, state) {
          return CustomButton(
            label: _currentStep == 4 ? 'Ro\'yxatdan o\'tish' : 'Davom etish',
            isLoading: state is OnboardingInProgress && _currentStep == 4,
            onPressed: _next,
            suffixIcon: _currentStep < 4 ? Icons.arrow_forward_rounded : null,
            prefixIcon: _currentStep == 4 ? Icons.check_rounded : null,
            variant: _currentStep == 4
                ? ButtonVariant.secondary
                : ButtonVariant.primary,
          );
        },
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text(value,
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
