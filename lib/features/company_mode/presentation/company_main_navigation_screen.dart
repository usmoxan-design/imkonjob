import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class CompanyMainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CompanyMainNavigationScreen(
      {super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index,
                initialLocation: index == navigationShell.currentIndex),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded,
                color: AppColors.primary),
            label: _navLabel('Bosh sahifa'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment_rounded,
                color: AppColors.primary),
            label: _navLabel('Buyurtmalar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.business_outlined),
            selectedIcon: const Icon(Icons.business_rounded,
                color: AppColors.primary),
            label: _navLabel('Profil'),
          ),
        ],
      ),
    );
  }

  String _navLabel(String text) => text;
}
