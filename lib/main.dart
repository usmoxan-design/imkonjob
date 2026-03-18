import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/bloc/chat_event.dart';
import 'features/company_mode/bloc/company_mode_bloc.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/notifications/bloc/notifications_bloc.dart';
import 'features/orders/bloc/orders_bloc.dart';
import 'features/posts/bloc/posts_bloc.dart';
import 'features/posts/bloc/posts_event.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/provider_mode/bloc/provider_mode_bloc.dart';
import 'features/providers/bloc/providers_bloc.dart';
import 'features/quick_order/bloc/quick_order_bloc.dart';
import 'features/reviews/bloc/review_bloc.dart';
import 'features/scheduled_order/bloc/scheduled_order_bloc.dart';
import 'features/tender_order/bloc/tender_order_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ImkonJobApp());
}

class ImkonJobApp extends StatefulWidget {
  const ImkonJobApp({super.key});

  @override
  State<ImkonJobApp> createState() => _ImkonJobAppState();
}

class _ImkonJobAppState extends State<ImkonJobApp> {
  late final AuthBloc _authBloc;
  late final ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _chatBloc = ChatBloc()..add(const LoadChatRooms());
  }

  @override
  void dispose() {
    _authBloc.close();
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ChatBloc>.value(value: _chatBloc),
        BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
        BlocProvider<OrdersBloc>(create: (_) => OrdersBloc()),
        BlocProvider<ProvidersBloc>(create: (_) => ProvidersBloc()),
        BlocProvider<QuickOrderBloc>(create: (_) => QuickOrderBloc()),
        BlocProvider<ScheduledOrderBloc>(create: (_) => ScheduledOrderBloc()),
        BlocProvider<ProfileBloc>(create: (_) => ProfileBloc()),
        BlocProvider<NotificationsBloc>(create: (_) => NotificationsBloc()),
        BlocProvider<ProviderModeBloc>(create: (_) => ProviderModeBloc()),
        BlocProvider<PostsBloc>(
            create: (_) => PostsBloc()..add(const LoadAllPosts())),
        BlocProvider<ReviewBloc>(create: (_) => ReviewBloc()),
        BlocProvider<CompanyModeBloc>(create: (_) => CompanyModeBloc()),
        BlocProvider<TenderOrderBloc>(create: (_) => TenderOrderBloc()),
      ],
      child: _RouterApp(authBloc: _authBloc),
    );
  }
}

class _RouterApp extends StatefulWidget {
  final AuthBloc authBloc;

  const _RouterApp({required this.authBloc});

  @override
  State<_RouterApp> createState() => _RouterAppState();
}

class _RouterAppState extends State<_RouterApp> {
  late final _router = createRouter(context);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, dynamic>(
      listener: (context, state) {
        // Router redirect handles navigation automatically
      },
      child: MaterialApp.router(
        title: 'Imkon Job',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
