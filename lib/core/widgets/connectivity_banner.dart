import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  late AnimationController _animCtrl;

  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Check initial connectivity
    Connectivity().checkConnectivity().then(_handleResult);

    // Listen for changes
    _sub = Connectivity()
        .onConnectivityChanged
        .listen(_handleResult);
  }

  void _handleResult(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline) {
      setState(() => _isOffline = offline);
      if (offline) {
        _animCtrl.forward();
      } else {
        _animCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, -1), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _animCtrl, curve: Curves.easeOut)),
              child: _OfflineBanner(),
            ),
          ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: const Color(0xFFD32F2F),
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 8,
          16,
          10,
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Internet aloqasi yo\'q',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}
