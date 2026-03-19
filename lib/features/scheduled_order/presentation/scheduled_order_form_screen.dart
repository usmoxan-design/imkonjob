import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/scheduled_order_bloc.dart';
import '../bloc/scheduled_order_event.dart';
import '../bloc/scheduled_order_state.dart';

class ScheduledOrderFormScreen extends StatefulWidget {
  const ScheduledOrderFormScreen({super.key});

  @override
  State<ScheduledOrderFormScreen> createState() =>
      _ScheduledOrderFormScreenState();
}

class _ScheduledOrderFormScreenState extends State<ScheduledOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _descController = TextEditingController();
  final _addressController =
      TextEditingController(text: AppConstants.defaultLocation);
  final _budgetController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sana va vaqtni tanlang')),
      );
      return;
    }
    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final budget = double.tryParse(_budgetController.text);
    context.read<ScheduledOrderBloc>().add(SubmitScheduledOrder(
          serviceType: _selectedCategory ?? 'Xizmat',
          description: _descController.text,
          address: _addressController.text,
          scheduledAt: scheduledAt,
          budget: budget,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduledOrderBloc, ScheduledOrderState>(
      listener: (context, state) {
        if (state is ScheduledOrderProposalsReceived) {
          context.push('/home/scheduled-order/proposals');
        } else if (state is ScheduledOrderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          title: const Text('Rejalashtirilgan xizmat'),
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
                _label('Xizmat turi'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  hint: Text('Kategoriya tanlang',
                      style: GoogleFonts.nunito(
                          fontSize: 14, color: context.txtSecondary)),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.surf,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.borderClr),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.borderClr),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  items: MockData.categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.icon} ${c.name}',
                                style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Kategoriya tanlang' : null,
                ),
                const SizedBox(height: 20),
                _label('Sana va vaqt'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DateTimeButton(
                        icon: Icons.calendar_today_rounded,
                        label: _selectedDate == null
                            ? 'Sana tanlang'
                            : DateFormat('dd MMMM', 'uz')
                                .format(_selectedDate!),
                        onTap: _pickDate,
                        filled: _selectedDate != null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateTimeButton(
                        icon: Icons.access_time_rounded,
                        label: _selectedTime == null
                            ? 'Vaqt tanlang'
                            : _selectedTime!.format(context),
                        onTap: _pickTime,
                        filled: _selectedTime != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _label('Tavsif'),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _descController,
                  hint: 'Xizmat haqida batafsil yozing...',
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Tavsif kiriting' : null,
                ),
                const SizedBox(height: 20),
                _label('Manzil'),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _addressController,
                  hint: 'Manzilingiz',
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.textSecondary),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Manzil kiriting' : null,
                ),
                const SizedBox(height: 20),
                _label('Taxminiy byudjet (ixtiyoriy)'),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _budgetController,
                  hint: 'Masalan: 100000',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.attach_money_rounded,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                BlocBuilder<ScheduledOrderBloc, ScheduledOrderState>(
                  builder: (context, state) {
                    return CustomButton(
                      label: 'Xizmat topish',
                      isLoading: state is ScheduledOrderSubmitting,
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

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: context.txtSecondary,
        ),
      );
}

class _DateTimeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _DateTimeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? context.primaryLightClr : context.surf,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: filled ? AppColors.primary : context.borderClr,
            width: filled ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: filled ? AppColors.primary : context.txtSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: filled ? AppColors.primary : context.txtSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
