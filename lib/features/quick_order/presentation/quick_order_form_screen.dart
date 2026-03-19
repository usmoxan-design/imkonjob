import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/custom_button.dart';
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
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  String _urgency = 'now';

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  final List<Map<String, String>> _savedLocations = [
    {'name': 'Uyim', 'address': 'Yunusobod 11-kvartal, Toshkent'},
    {'name': 'Ishxonam', 'address': 'Amir Temur ko\'chasi 108, Toshkent'},
  ];

  @override
  void dispose() {
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<QuickOrderBloc>().add(SubmitQuickOrder(
            serviceType: _selectedCategoryName ?? '',
            description: _descController.text,
            address: _addressController.text,
            urgency: _urgency,
          ));
    }
  }

  Future<void> _startVoiceInput() async {
    final available = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: 'uz_UZ',
        onResult: (r) {
          setState(() => _descController.text = r.recognizedWords);
          if (r.finalResult) setState(() => _isListening = false);
        },
      );
    }
  }

  void _stopVoiceInput() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _showCategorySheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kategoriya tanlang',
                      style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color:
                    isDark ? AppColors.darkBorder : AppColors.border),
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: MockData.categories.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, indent: 56,
                        color: isDark ? AppColors.darkBorder : AppColors.border),
                itemBuilder: (_, i) {
                  final cat = MockData.categories[i];
                  final selected = _selectedCategoryId == cat.id;
                  return ListTile(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = cat.id;
                        _selectedCategoryName = cat.name;
                      });
                      Navigator.pop(context);
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryLight
                            : (isDark
                                ? AppColors.darkSurface2
                                : AppColors.muted),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Text(cat.icon,
                              style: const TextStyle(fontSize: 20))),
                    ),
                    title: Text(cat.name,
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 20)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Manzil tanlang',
                  style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary)),
            ),
            Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.border),
            ..._savedLocations.map((loc) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      loc['name'] == 'Uyim'
                          ? Icons.home_rounded
                          : Icons.work_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(loc['name']!,
                      style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary)),
                  subtitle: Text(loc['address']!,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary)),
                  onTap: () {
                    setState(
                        () => _addressController.text = loc['address']!);
                    Navigator.pop(context);
                  },
                )),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.my_location_rounded,
                    color: AppColors.teal, size: 20),
              ),
              title: Text('Hozirgi joylashuv',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary)),
              subtitle: Text('GPS orqali avtomatik aniqlash',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)),
              onTap: () {
                setState(() =>
                    _addressController.text = AppConstants.defaultLocation);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.orangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map_rounded,
                    color: AppColors.orange, size: 20),
              ),
              title: Text('Haritadan tanlash',
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary)),
              subtitle: Text('Xaritada aniq nuqtani belgilang',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<QuickOrderBloc, QuickOrderState>(
      listener: (context, state) {
        if (state is QuickOrderSearching) {
          context.push('/home/quick-order/waiting');
        } else if (state is QuickOrderError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
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
                _sectionTitle('Xizmat turi *', isDark),
                const SizedBox(height: 10),
                _buildCategorySelector(context, isDark),
                const SizedBox(height: 20),
                _sectionTitle('Muammo tavsifi *', isDark),
                const SizedBox(height: 10),
                _buildDescriptionField(isDark),
                const SizedBox(height: 20),
                _sectionTitle('Manzil *', isDark),
                const SizedBox(height: 10),
                _buildLocationSelector(context, isDark),
                const SizedBox(height: 20),
                _sectionTitle('Qachon kerak?', isDark),
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
                        isDark: isDark,
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
                        isDark: isDark,
                      ),
                    ),
                  ],
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

  Widget _sectionTitle(String title, bool isDark) => Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      );

  Widget _buildCategorySelector(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showCategorySheet(context, isDark),
      child: FormField<String>(
        validator: (_) =>
            _selectedCategoryId == null ? 'Kategoriya tanlang' : null,
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.hasError
                      ? AppColors.error
                      : (_selectedCategoryId != null
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.border)),
                  width: _selectedCategoryId != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (_selectedCategoryId != null) ...[
                    Text(
                      MockData.categories
                          .firstWhere((c) => c.id == _selectedCategoryId)
                          .icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                  ] else
                    Icon(Icons.category_outlined,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextHint
                            : AppColors.textHint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedCategoryName ?? 'Kategoriya tanlang',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: _selectedCategoryId != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _selectedCategoryId != null
                            ? (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)
                            : (isDark
                                ? AppColors.darkTextHint
                                : AppColors.textHint),
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color:
                          isDark ? AppColors.darkTextHint : AppColors.textHint),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(state.errorText!,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: AppColors.error)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _descController,
                maxLines: 4,
                minLines: 3,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Muammoni batafsil yozing...',
                  hintStyle: GoogleFonts.nunito(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextHint
                          : AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                  filled: false,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Tavsif kiriting' : null,
              ),
              Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Text(
                      'Ovozli kiritish',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (_isListening)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.error),
                            ),
                            const SizedBox(width: 6),
                            Text('Tinglayapman...',
                                style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    GestureDetector(
                      onTap: _isListening ? _stopVoiceInput : _startVoiceInput,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isListening
                              ? AppColors.error
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showLocationSheet(context, isDark),
      child: FormField<String>(
        validator: (_) =>
            _addressController.text.trim().isEmpty ? 'Manzil tanlang' : null,
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.hasError
                      ? AppColors.error
                      : (_addressController.text.isNotEmpty
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.border)),
                  width: _addressController.text.isNotEmpty ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _addressController.text.isEmpty
                          ? 'Manzil tanlang'
                          : _addressController.text,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: _addressController.text.isNotEmpty
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _addressController.text.isNotEmpty
                            ? (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)
                            : (isDark
                                ? AppColors.darkTextHint
                                : AppColors.textHint),
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color:
                          isDark ? AppColors.darkTextHint : AppColors.textHint),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(state.errorText!,
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: AppColors.error)),
              ),
          ],
        ),
      ),
    );
  }
}

class _UrgencyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _UrgencyChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryLight
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.border),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: selected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
