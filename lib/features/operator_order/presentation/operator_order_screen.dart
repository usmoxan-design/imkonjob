import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';

class OperatorOrderScreen extends StatefulWidget {
  const OperatorOrderScreen({super.key});

  @override
  State<OperatorOrderScreen> createState() => _OperatorOrderScreenState();
}

class _OperatorOrderScreenState extends State<OperatorOrderScreen> {
  final _nameCtrl = TextEditingController(text: 'Foydalanuvchi');
  final _phoneCtrl = TextEditingController(text: '+998 90 123 45 67');
  String? _selectedService;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _callOperator() async {
    final uri = Uri.parse('tel:${AppConstants.supportPhone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Qo\'ng\'iroq qilishda xatolik',
                style: GoogleFonts.nunito(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _requestCallback() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ism va telefon raqamni kiriting',
              style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    size: 36, color: AppColors.success),
              ),
              const SizedBox(height: 16),
              Text('So\'rov qabul qilindi!',
                  style: GoogleFonts.nunito(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                'Operatorimiz ${_phoneCtrl.text} raqamiga 15 daqiqa ichida qo\'ng\'iroq qiladi.',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: Text('Yopish',
                  style: GoogleFonts.nunito(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Operator orqali topish',
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
            // Explanation card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operator xizmati',
                            style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Bizning operatorlarimiz sizga mos usta topishda yordam beradi',
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Phone number display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text('Qo\'ng\'iroq qiling',
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Text(
                    AppConstants.supportPhone,
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text('Ish vaqti: 08:00 - 22:00, Har kuni',
                            style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: 'Qo\'ng\'iroq qilish',
                    prefixIcon: Icons.phone_rounded,
                    onPressed: _callOperator,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('yoki',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            Text('Quyida ma\'lumot qoldiring',
                style: GoogleFonts.nunito(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Operator siz bilan bog\'lanadi',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            _label('Ismingiz'),
            CustomTextField(
              controller: _nameCtrl,
              hint: 'To\'liq ismingiz',
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _label('Telefon raqam'),
            CustomTextField(
              controller: _phoneCtrl,
              hint: '+998 XX XXX XX XX',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            _label('Xizmat turi'),
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
                  value: _selectedService,
                  hint: Text('Xizmat turini tanlang',
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
                      setState(() => _selectedService = val),
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Qayta qo\'ng\'iroq so\'rash',
              prefixIcon: Icons.call_received_rounded,
              isLoading: _isSubmitting,
              onPressed: _requestCallback,
            ),
            const SizedBox(height: 32),
          ],
        ),
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
}
