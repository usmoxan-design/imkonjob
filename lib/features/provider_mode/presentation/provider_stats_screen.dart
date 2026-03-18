import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ProviderStatsScreen extends StatelessWidget {
  const ProviderStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = [12, 8, 15, 10, 18, 14, 9];
    final days = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
    final maxVal = weeklyData.reduce((a, b) => a > b ? a : b).toDouble();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Statistika')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TopStatCard(
                    value: '86', label: 'Jami buyurtma', color: AppColors.primary),
                const SizedBox(width: 12),
                _TopStatCard(
                    value: '4.8', label: 'O\'rtacha reyting', color: AppColors.yellow),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TopStatCard(
                    value: '96%', label: 'Bajarish darajasi', color: AppColors.success),
                const SizedBox(width: 12),
                _TopStatCard(
                    value: '2.1M', label: 'Bu oy daromad', color: AppColors.orange),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Haftalik faollik',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(7, (i) {
                        final ratio = weeklyData[i] / maxVal;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${weeklyData[i]}',
                              style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              width: 28,
                              height: 100 * ratio,
                              decoration: BoxDecoration(
                                color: i == 4
                                    ? AppColors.primary
                                    : AppColors.primaryLight,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: days
                        .map((d) => Text(d,
                            style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: AppColors.textSecondary)))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oylik daromad',
              style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ..._monthlyEarnings().map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.$1,
                          style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      Text(
                        item.$2,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<(String, String)> _monthlyEarnings() {
    return [
      ('Mart 2026', '2,100,000 so\'m'),
      ('Fevral 2026', '1,850,000 so\'m'),
      ('Yanvar 2026', '2,300,000 so\'m'),
    ];
  }
}

class _TopStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _TopStatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
