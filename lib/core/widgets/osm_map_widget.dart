import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _tashkentCenter = LatLng(41.2995, 69.2401);

class OsmMapWidget extends StatelessWidget {
  final LatLng? center;
  final List<Marker> markers;
  final double zoom;
  final bool interactive;

  const OsmMapWidget({
    this.center,
    this.markers = const [],
    this.zoom = 13.0,
    this.interactive = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center ?? _tashkentCenter,
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.imkonjob.app',
          maxZoom: 19,
        ),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
      ],
    );
  }
}

Marker providerMarker({
  required LatLng position,
  required VoidCallback onTap,
  bool isOnline = true,
}) {
  return Marker(
    point: position,
    width: 40,
    height: 40,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isOnline ? const Color(0xFF10B981) : const Color(0xFF64748B),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 20),
      ),
    ),
  );
}
