import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/company_mode_bloc.dart';
import '../bloc/company_mode_event.dart';
import '../bloc/company_mode_state.dart';

class CompanyOnboardingScreen extends StatefulWidget {
  const CompanyOnboardingScreen({super.key});

  @override
  State<CompanyOnboardingScreen> createState() =>
      _CompanyOnboardingScreenState();
}

class _CompanyOnboardingScreenState extends State<CompanyOnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+998 90 123 45 67');

  // Step 2
  final Set<String> _selectedCategories = {};

  // Step 3
  final _locationCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '09:00 - 21:00');
  bool _offersWarranty = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _submit() {
    context.read<CompanyModeBloc>().add(SubmitCompanyOnboarding({
          'name': _nameCtrl.text,
          'description': _descCtrl.text,
          'phone': _phoneCtrl.text,
          'categories': _selectedCategories.toList(),
          'location': _locationCtrl.text,
          'workingHours': _hoursCtrl.text,
          'offersWarranty': _offersWarranty,
        }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyModeBloc, CompanyModeState>(
      listener: (context, state) {
        if (state is CompanyModeActive) {
          context.go('/company/dashboard');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Kompaniya ro\'yxatdan o\'tish',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: _back,
          ),
        ),
        body: Column(
          children: [
            _buildStepper(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    const steps = ['Ma\'lumot', 'Xizmatlar', 'Hudud', 'Tasdiqlash'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final label = e.value;
          final isDone = i < _currentStep;
          final isCurrent = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.success
                              : isCurrent
                                  ? AppColors.primary
                                  : AppColors.grey200,
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check_rounded,
                                  size: 14, color: Colors.white)
                              : Text(
                                  '${i + 1}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isCurrent
                                        ? Colors.white
                                        : AppColors.grey500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: i < _currentStep
                          ? AppColors.success
                          : AppColors.grey300,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kompaniya ma\'lumotlari',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Kompaniyangiz haqida asosiy ma\'lumotlarni kiriting',
              style: GoogleFonts.nunito(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _label('Kompaniya nomi'),
          CustomTextField(
            controller: _nameCtrl,
            hint: 'Masalan: Pro Services Toshkent',
          ),
          const SizedBox(height: 16),
          _label('Tavsif'),
          CustomTextField(
            controller: _descCtrl,
            hint: 'Kompaniyangiz haqida qisqacha...',
            maxLines: 4,
            minLines: 3,
          ),
          const SizedBox(height: 16),
          _label('Telefon raqam'),
          CustomTextField(
            controller: _phoneCtrl,
            hint: '+998 XX XXX XX XX',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xizmat turlari',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Kompaniyangiz qanday xizmatlar ko\'rsatadi?',
              style: GoogleFonts.nunito(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: MockData.categories.map((cat) {
              final selected = _selectedCategories.contains(cat.name);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _selectedCategories.remove(cat.name);
                  } else {
                    _selectedCategories.add(cat.name);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryLight
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle_rounded,
                            size: 14, color: AppColors.primary),
                      ],
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ish hududi va vaqti',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Qayerda va qachon xizmat ko\'rsatasiz?',
              style: GoogleFonts.nunito(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _label('Manzil / Hudud'),
          CustomTextField(
            controller: _locationCtrl,
            hint: 'Masalan: Toshkent shahar',
            prefixIcon: const Icon(Icons.location_on_outlined,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _label('Ish vaqti'),
          CustomTextField(
            controller: _hoursCtrl,
            hint: '09:00 - 21:00',
            prefixIcon: const Icon(Icons.access_time_rounded,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kafolat berasizmi?',
                          style: GoogleFonts.nunito(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Ishlaringizga kafolat berishingiz imkoningiz bormi?',
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Switch(
                  value: _offersWarranty,
                  onChanged: (val) =>
                      setState(() => _offersWarranty = val),
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

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ma\'lumotlarni tekshiring',
              style: GoogleFonts.nunito(
                  fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _summaryCard('Kompaniya nomi',
              _nameCtrl.text.isEmpty ? '—' : _nameCtrl.text),
          _summaryCard('Telefon', _phoneCtrl.text),
          _summaryCard('Xizmatlar',
              _selectedCategories.isEmpty
                  ? '—'
                  : _selectedCategories.join(', ')),
          _summaryCard('Manzil',
              _locationCtrl.text.isEmpty ? '—' : _locationCtrl.text),
          _summaryCard('Ish vaqti', _hoursCtrl.text),
          _summaryCard('Kafolat', _offersWarranty ? 'Ha' : 'Yo\'q'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tekshirilgandan keyin tasdiqlash xabarnomasini olasiz. Odatda 1-2 ish kuni.',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.primary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary)),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BlocBuilder<CompanyModeBloc, CompanyModeState>(
        builder: (context, state) => CustomButton(
          label: _currentStep < 3 ? 'Davom etish' : 'Ariza yuborish',
          prefixIcon: _currentStep < 3
              ? Icons.arrow_forward_rounded
              : Icons.send_rounded,
          isLoading: state is CompanyOnboardingSubmitting,
          onPressed: _next,
        ),
      ),
    );
  }
}
