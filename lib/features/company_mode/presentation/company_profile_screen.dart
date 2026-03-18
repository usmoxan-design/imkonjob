import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/company_mode_bloc.dart';
import '../bloc/company_mode_state.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Pro Services Toshkent');
  final _descCtrl = TextEditingController(
      text: 'Toshkentdagi eng ishonchli xizmat ko\'rsatish kompaniyasi.');
  final _phoneCtrl = TextEditingController(text: '+998 71 234 56 78');
  final _hoursCtrl = TextEditingController(text: '08:00 - 22:00');
  final _locationCtrl = TextEditingController(text: 'Yunusobod, Toshkent');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _hoursCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Kompaniya profili',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: BlocBuilder<CompanyModeBloc, CompanyModeState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage:
                            const NetworkImage('https://i.pravatar.cc/150?img=50'),
                        backgroundColor: AppColors.grey200,
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _label('Kompaniya nomi'),
                CustomTextField(controller: _nameCtrl, hint: 'Kompaniya nomi'),
                const SizedBox(height: 16),
                _label('Tavsif'),
                CustomTextField(
                  controller: _descCtrl,
                  hint: 'Kompaniya haqida...',
                  maxLines: 3,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                _label('Telefon'),
                CustomTextField(
                  controller: _phoneCtrl,
                  hint: '+998 XX XXX XX XX',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _label('Manzil'),
                CustomTextField(
                  controller: _locationCtrl,
                  hint: 'Shahar, tuman',
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
                const SizedBox(height: 32),
                CustomButton(
                  label: 'Saqlash',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profil yangilandi',
                            style: GoogleFonts.nunito(color: Colors.white)),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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
