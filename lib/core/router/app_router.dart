import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/name_input_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/chat/presentation/chat_detail_screen.dart';
import '../../features/chat/presentation/chat_list_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/main/main_navigation_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/profile/presentation/profile_edit_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/provider_mode/presentation/provider_dashboard_screen.dart';
import '../../features/provider_mode/presentation/provider_main_navigation_screen.dart';
import '../../features/provider_mode/presentation/provider_onboarding_screen.dart';
import '../../features/provider_mode/presentation/provider_orders_screen.dart';
import '../../features/provider_mode/presentation/provider_profile_screen.dart';
import '../../features/provider_mode/presentation/provider_stats_screen.dart';
import '../../features/providers/presentation/provider_detail_screen.dart';
import '../../features/providers/presentation/providers_screen.dart';
import '../../features/quick_order/presentation/quick_order_form_screen.dart';
import '../../features/quick_order/presentation/quick_order_proposals_screen.dart';
import '../../features/quick_order/presentation/quick_order_waiting_screen.dart';
import '../../features/scheduled_order/presentation/scheduled_order_form_screen.dart';
import '../../features/scheduled_order/presentation/scheduled_order_proposals_screen.dart';
import '../models/chat_model.dart';
import '../models/order_model.dart';
import '../models/provider_model.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorOrdersKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellOrders');
final _shellNavigatorChatKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellChat');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final _providerShellDashboardKey =
    GlobalKey<NavigatorState>(debugLabel: 'providerDashboard');
final _providerShellOrdersKey =
    GlobalKey<NavigatorState>(debugLabel: 'providerOrders');
final _providerShellProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'providerProfile');
final _providerShellStatsKey =
    GlobalKey<NavigatorState>(debugLabel: 'providerStats');

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final location = state.matchedLocation;

      final publicRoutes = ['/splash', '/phone', '/otp', '/name'];
      final isPublic = publicRoutes.any((r) => location.startsWith(r));

      if (authState is AuthAuthenticated && location == '/splash') {
        return '/home';
      }
      if (authState is AuthUnauthenticated && !isPublic) {
        return '/phone';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/name',
        builder: (context, state) => const NameInputScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/provider/onboarding',
        builder: (context, state) => const ProviderOnboardingScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final order = state.extra as OrderModel?;
          if (order != null) {
            return OrderDetailScreen(order: order);
          }
          return const Scaffold(
            body: Center(child: Text('Buyurtma topilmadi')),
          );
        },
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final room = state.extra as ChatRoomModel?;
          if (room != null) {
            return ChatDetailScreen(room: room);
          }
          return const Scaffold(
            body: Center(child: Text('Chat topilmadi')),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainNavigationScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'quick-order',
                    builder: (context, state) =>
                        const QuickOrderFormScreen(),
                    routes: [
                      GoRoute(
                        path: 'waiting',
                        builder: (context, state) =>
                            const QuickOrderWaitingScreen(),
                      ),
                      GoRoute(
                        path: 'proposals',
                        builder: (context, state) =>
                            const QuickOrderProposalsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'scheduled-order',
                    builder: (context, state) =>
                        const ScheduledOrderFormScreen(),
                    routes: [
                      GoRoute(
                        path: 'proposals',
                        builder: (context, state) =>
                            const ScheduledOrderProposalsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'providers',
                    builder: (context, state) => const ProvidersScreen(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) {
                          final provider =
                              state.extra as ProviderModel?;
                          if (provider != null) {
                            return ProviderDetailScreen(provider: provider);
                          }
                          return const Scaffold(
                            body: Center(child: Text('Usta topilmadi')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOrdersKey,
            routes: [
              GoRoute(
                path: '/orders-tab',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorChatKey,
            routes: [
              GoRoute(
                path: '/chat-list',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ProviderMainNavigationScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _providerShellDashboardKey,
            routes: [
              GoRoute(
                path: '/provider/dashboard',
                builder: (context, state) =>
                    const ProviderDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _providerShellOrdersKey,
            routes: [
              GoRoute(
                path: '/provider/orders',
                builder: (context, state) => const ProviderOrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _providerShellProfileKey,
            routes: [
              GoRoute(
                path: '/provider/profile',
                builder: (context, state) => const ProviderProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _providerShellStatsKey,
            routes: [
              GoRoute(
                path: '/provider/stats',
                builder: (context, state) => const ProviderStatsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
