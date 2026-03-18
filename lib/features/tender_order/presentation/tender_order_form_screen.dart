import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/tender_order_bloc.dart';
import '../bloc/tender_order_event.dart';
import '../bloc/tender_order_state.dart';

class TenderOrderFormScreen extends StatefulWidget {
  const TenderOrderFormScreen({super.key});

  @override
  State<TenderOrderFormScreen> createState() =>
      _TenderOrderFormScreenState();
}

class _TenderOrderFormScreenState extends State<TenderOrderFormScreen> {
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  String? _selectedService;
  DateTime _deadline = DateTime.now().add(const Duration(days: 3));
  bool _waitForProposal = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    if (_selectedService == null ||
        _descCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barcha majburiy maydonlarni to\'ldiring',
              style: GoogleFonts.nunito(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    context.read<TenderOrderBloc>().add(SubmitTenderOrder(
          serviceType: _selectedService!,
          description: _descCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          budget: _waitForProposal
              ? null
              : _budgetCtrl.text.trim().isEmpty
                  ? null
                  : _budgetCtrl.text.trim(),
          deadline: _deadline,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TenderOrderBloc, TenderOrderState>(
      listener: (context, state) {
        if (state is TenderProposalsReceived) {
          context.push('/tender-order/proposals', extra: state.proposals);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Ochiq buyurtma',
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
                    const Icon(Icons.people_outline_rounded,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bir nechta ustalardan taklif oling va eng yaxshisini tanlang',
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
              const SizedBox(height: 20),
              _label('Xizmat turi *'),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
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
                            fontSize: 14,
                            color: AppColors.textSecondary)),
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
              const SizedBox(height: 16),
              _label('Tavsif *'),
              CustomTextField(
                controller: _descCtrl,
                hint:
                    'Kerakli ishni batafsil tasvirlab bering: hajmi, materiali, o\'lchamlari...',
                maxLines: 5,
                minLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              _label('Manzil *'),
              CustomTextField(
                controller: _addressCtrl,
                hint: 'Ko\'cha, uy raqami, qavat',
                prefixIcon: const Icon(Icons.location_on_outlined,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _label('Byudjet')),
                  Row(
                    children: [
                      Checkbox(
                        value: _waitForProposal,
                        onChanged: (val) =>
                            setState(() => _waitForProposal = val ?? false),
                        activeColor: AppColors.primary,
                      ),
                      Text('Taklif kutaman',
                          style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              if (!_waitForProposal)
                CustomTextField(
                  controller: _budgetCtrl,
                  hint: 'Masalan: 500,000 so\'m',
                  prefixIcon: const Icon(Icons.payments_outlined,
                      color: AppColors.textSecondary),
                  keyboardType: TextInputType.text,
                ),
              const SizedBox(height: 16),
              _label('Muddat'),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_deadline),
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_library_outlined,
                        color: AppColors.textSecondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rasm qo\'shish',
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text(
                              'Keyingi versiyada mavjud bo\'ladi',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<TenderOrderBloc, TenderOrderState>(
                builder: (context, state) => CustomButton(
                  label: 'E\'lon berish',
                  prefixIcon: Icons.campaign_rounded,
                  isLoading: state is TenderOrderSubmitting,
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
