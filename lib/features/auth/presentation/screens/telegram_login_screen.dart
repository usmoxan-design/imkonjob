import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';

class TelegramLoginScreen extends StatefulWidget {
  const TelegramLoginScreen({super.key});

  @override
  State<TelegramLoginScreen> createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends State<TelegramLoginScreen> {
  late final WebViewController _controller;

  static const String _telegramHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      background: #f0f4f8;
      font-family: -apple-system, sans-serif;
      padding: 20px;
    }
    .logo {
      width: 80px;
      height: 80px;
      background: linear-gradient(135deg, #2563EB, #1d4ed8);
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 16px;
    }
    .logo-text { color: white; font-size: 28px; font-weight: 800; }
    h1 { font-size: 20px; color: #0f172a; margin-bottom: 8px; }
    p { font-size: 14px; color: #64748b; margin-bottom: 32px; text-align: center; }
    .widget-wrapper { display: flex; justify-content: center; }
  </style>
</head>
<body>
  <div class="logo"><span class="logo-text">IJ</span></div>
  <h1>Imkon Job</h1>
  <p>Telegram akkauntingiz bilan kiring</p>
  <div class="widget-wrapper">
    <script async src="https://telegram.org/js/telegram-widget.js?22"
      data-telegram-login="imkonjob_bot"
      data-size="large"
      data-radius="8"
      data-onauth="onTelegramAuth(user)"
      data-request-access="write">
    </script>
  </div>
  <script>
    function onTelegramAuth(user) {
      TelegramChannel.postMessage(JSON.stringify(user));
    }
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'TelegramChannel',
        onMessageReceived: (msg) {
          try {
            final Map<String, dynamic> userData =
                Map<String, dynamic>.from(
                  (jsonDecode(msg.message) as Map).cast<String, dynamic>(),
                );
            context
                .read<AuthBloc>()
                .add(TelegramSignInCompleted(telegramUser: userData));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Telegram orqali kirishda xato: $e')),
            );
          }
        },
      )
      ..loadHtmlString(_telegramHtml, baseUrl: 'http://127.0.0.1');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is NeedsProfileSetup) {
          context.go('/name', extra: {
            'name': state.prefilledName,
            'avatar': state.prefilledAvatar,
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFD93025),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Telegram bilan kirish'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
