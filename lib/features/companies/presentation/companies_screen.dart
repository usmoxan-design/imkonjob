import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../../../core/models/company_model.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _searchController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _query = '';
  String? _selectedCategory;

  final List<CompanyModel> _companies = [
    CompanyModel(
      id: 'c1',
      name: 'MasterPro Kompaniyasi',
      logo: 'https://i.pravatar.cc/150?img=10',
      description: 'Santexnika, elektr va qurilish ishlari bo\'yicha professionallar',
      isVerified: true,
      rating: 4.9,
      reviewCount: 312,
      serviceCategories: ['Santexnika', 'Elektr', 'Qurilish'],
      location: 'Yunusobod, Toshkent',
      phone: '+998901234567',
      workingHours: '08:00 – 20:00',
      completedOrders: 1420,
      priceRange: '50 000 – 500 000 so\'m',
      portfolio: [
        'https://picsum.photos/seed/c1a/400/300',
        'https://picsum.photos/seed/c1b/400/300',
      ],
    ),
    CompanyModel(
      id: 'c2',
      name: 'CleanHome Services',
      logo: 'https://i.pravatar.cc/150?img=20',
      description: 'Uy va ofislarni professional tozalash xizmatlari',
      isVerified: true,
      rating: 4.7,
      reviewCount: 208,
      serviceCategories: ['Tozalash', 'Laundry', 'Dezinfeksiya'],
      location: 'Chilonzor, Toshkent',
      phone: '+998907654321',
      workingHours: '07:00 – 22:00',
      completedOrders: 890,
      priceRange: '30 000 – 200 000 so\'m',
      portfolio: [
        'https://picsum.photos/seed/c2a/400/300',
        'https://picsum.photos/seed/c2b/400/300',
      ],
    ),
    CompanyModel(
      id: 'c3',
      name: 'FixIt Express',
      logo: 'https://i.pravatar.cc/150?img=30',
      description: 'Tezkor maishiy texnikalar ta\'miri va xizmat ko\'rsatish',
      isVerified: false,
      rating: 4.5,
      reviewCount: 140,
      serviceCategories: ['Maishiy texnika', 'Konditsioner', 'Muzlatgich'],
      location: 'Mirzo Ulug\'bek, Toshkent',
      phone: '+998909876543',
      workingHours: '09:00 – 21:00',
      completedOrders: 560,
      priceRange: '40 000 – 300 000 so\'m',
      portfolio: [
        'https://picsum.photos/seed/c3a/400/300',
      ],
    ),
    CompanyModel(
      id: 'c4',
      name: 'BuildCraft Pro',
      logo: 'https://i.pravatar.cc/150?img=40',
      description: 'Zamonaviy ta\'mirlash va dizayn ishlari bo\'yicha mutaxassislar',
      isVerified: true,
      rating: 4.8,
      reviewCount: 275,
      serviceCategories: ['Ta\'mirlash', 'Dizayn', 'Mebel'],
      location: 'Shayxontohur, Toshkent',
      phone: '+998901112233',
      workingHours: '08:00 – 19:00',
      completedOrders: 980,
      priceRange: '100 000 – 2 000 000 so\'m',
      portfolio: [
        'https://picsum.photos/seed/c4a/400/300',
        'https://picsum.photos/seed/c4b/400/300',
        'https://picsum.photos/seed/c4c/400/300',
      ],
    ),
    CompanyModel(
      id: 'c5',
      name: 'GardenPro Toshkent',
      logo: 'https://i.pravatar.cc/150?img=50',
      description: 'Bog\' va ko\'kalamzorlashtirish ishlari',
      isVerified: false,
      rating: 4.3,
      reviewCount: 87,
      serviceCategories: ['Bog\'dorchilik', 'Ko\'kalamzor', 'Maysazor'],
      location: 'Sergeli, Toshkent',
      phone: '+998903334455',
      workingHours: '08:00 – 18:00',
      completedOrders: 230,
      priceRange: '60 000 – 400 000 so\'m',
      portfolio: [
        'https://picsum.photos/seed/c5a/400/300',
      ],
    ),
  ];

  final List<String> _allCategories = [
    'Hammasi',
    'Qurilish',
    'Santexnika',
    'Elektr',
    'Tozalash',
    'Maishiy texnika',
    'Ta\'mirlash',
    'Bog\'dorchilik',
  ];

  List<CompanyModel> get _filtered {
    return _companies.where((c) {
      final matchQuery = _query.isEmpty ||
          c.name.toLowerCase().contains(_query.toLowerCase()) ||
          c.description.toLowerCase().contains(_query.toLowerCase()) ||
          c.serviceCategories
              .any((s) => s.toLowerCase().contains(_query.toLowerCase()));
      final matchCat = _selectedCategory == null ||
          _selectedCategory == 'Hammasi' ||
          c.serviceCategories.contains(_selectedCategory);
      return matchQuery && matchCat;
    }).toList();
  }

  Future<void> _startVoiceSearch() async {
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
          if (r.finalResult) {
            setState(() {
              _query = r.recognizedWords;
              _searchController.text = r.recognizedWords;
              _isListening = false;
            });
          }
        },
      );
    }
  }

  void _stopVoiceSearch() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filtered;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text(
          'Xizmat ko\'rsatuvchi kompaniyalar',
          style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildCategoryFilter(isDark),
          Expanded(
            child: results.isEmpty
                ? _buildEmpty(isDark)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _CompanyCard(company: results[i], isDark: isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded,
              color: isDark ? AppColors.darkTextHint : AppColors.textHint,
              size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Kompaniya yoki xizmat qidiring...',
                hintStyle: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextHint
                        : AppColors.textHint),
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          GestureDetector(
            onTap: _isListening ? _stopVoiceSearch : _startVoiceSearch,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isListening ? AppColors.error : AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _allCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _allCategories[i];
          final selected = _selectedCategory == cat ||
              (cat == 'Hammasi' && _selectedCategory == null);
          return GestureDetector(
            onTap: () => setState(() =>
                _selectedCategory = cat == 'Hammasi' ? null : cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkSurface : AppColors.surface),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              child: Text(
                cat,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextHint : AppColors.textHint),
          const SizedBox(height: 12),
          Text('Kompaniya topilmadi',
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final CompanyModel company;
  final bool isDark;

  const _CompanyCard({required this.company, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => CompanyDetailScreen(company: company),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        company.name[0],
                        style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                company.name,
                                style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (company.isVerified)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded,
                                        size: 12, color: AppColors.success),
                                    const SizedBox(width: 3),
                                    Text('Tasdiqlangan',
                                        style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.success)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFFBBC04)),
                            const SizedBox(width: 3),
                            Text(
                              company.rating.toStringAsFixed(1),
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${company.reviewCount} sharh)',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_outline_rounded,
                                size: 13, color: AppColors.success),
                            const SizedBox(width: 3),
                            Text(
                              '${company.completedOrders} buyurtma',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                company.description,
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: company.serviceCategories
                    .take(4)
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkPrimaryLight
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s,
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(company.location,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary)),
                  const Spacer(),
                  Text(company.priceRange,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone_rounded, size: 16),
                      label: Text('Qo\'ng\'iroq',
                          style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bolt_rounded, size: 16),
                      label: Text('Buyurtma',
                          style: GoogleFonts.nunito(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
