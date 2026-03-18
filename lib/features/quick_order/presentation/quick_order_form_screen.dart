import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/quick_order_bloc.dart';
import '../bloc/quick_order_event.dart';
import '../bloc/quick_order_state.dart';

class QuickOrderFormScreen extends StatefulWidget {
  const QuickOrderFormScreen({super.key});

  @override
  State<QuickOrderFormScreen> createState() => _QuickOrderFormScreenState();
}

class _QuickOrderFormScreenState extends State<QuickOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _descController = TextEditingController(text: '');
  final _addressController =
      TextEditingController(text: AppConstants.defaultLocation);
  String _urgency = 'now';

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<QuickOrderBloc>().add(SubmitQuickOrder(
            serviceType: _selectedCategory ?? 'Santexnik',
            description: _descController.text,
            address: _addressController.text,
            urgency: _urgency,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QuickOrderBloc, QuickOrderState>(
      listener: (context, state) {
        if (state is QuickOrderSearching) {
          context.push('/home/quick-order/waiting');
        } else if (state is QuickOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tezkor xizmat'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Xizmat turi'),
                const SizedBox(height: 10),
                _buildCategoryDropdown(),
                const SizedBox(height: 20),
                _sectionTitle('Muammo tavsifi'),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _descController,
                  hint: 'Muammoni batafsil yozing...',
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Tavsif kiriting' : null,
                ),
                const SizedBox(height: 20),
                _sectionTitle('Manzil'),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _addressController,
                  hint: 'Manzilingizni kiriting',
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.textSecondary),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Manzil kiriting' : null,
                ),
                const SizedBox(height: 20),
                _sectionTitle('Qachon kerak?'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _UrgencyChip(
                        label: 'Hozir kerak',
                        icon: Icons.bolt_rounded,
                        value: 'now',
                        selected: _urgency == 'now',
                        onTap: () => setState(() => _urgency = 'now'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _UrgencyChip(
                        label: '1 soat ichida',
                        icon: Icons.access_time_rounded,
                        value: '1h',
                        selected: _urgency == '1h',
                        onTap: () => setState(() => _urgency = '1h'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('Rasm qo\'shish (ixtiyoriy)'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined,
                              size: 32, color: AppColors.textSecondary),
                          const SizedBox(height: 6),
                          Text(
                            'Rasm qo\'shish',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<QuickOrderBloc, QuickOrderState>(
                  builder: (context, state) {
                    return CustomButton(
                      label: 'Xizmat topish',
                      isLoading: state is QuickOrderSubmitting,
                      onPressed: _submit,
                      prefixIcon: Icons.search_rounded,
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      );

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      hint: Text(
        'Kategoriya tanlang',
        style: GoogleFonts.nunito(
            fontSize: 14, color: AppColors.textSecondary),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: MockData.categories
          .map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(
                  '${c.icon} ${c.name}',
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
      validator: (v) => v == null ? 'Kategoriya tanlang' : null,
    );
  }
}

class _UrgencyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _UrgencyChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
