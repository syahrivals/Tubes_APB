import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/branch.dart';

class NavigationScreen extends StatefulWidget {
  final Branch branch;
  final LatLng? userPosition;

  const NavigationScreen({
    super.key,
    required this.branch,
    required this.userPosition,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  GoogleMapController? _mapController;

  // Posisi user yang terus diperbarui saat navigasi
  LatLng? _currentPosition;

  // Stream untuk melacak posisi GPS secara real-time
  StreamSubscription<Position>? _positionStream;

  // Jarak tersisa ke cabang
  double _distanceRemaining = 0;

  // Apakah user sudah tiba
  bool _hasArrived = false;

  // Polyline (garis rute) di peta
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.userPosition;
    _startTracking();
    _drawRoute();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // ── Mulai tracking posisi real-time ────────────────────────────────────────
  void _startTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update tiap user gerak 10 meter
      ),
    ).listen((Position position) {
      if (!mounted) return;

      final newPos = LatLng(position.latitude, position.longitude);

      // Hitung jarak ke tujuan
      double dist = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.branch.latitude,
        widget.branch.longitude,
      );

      setState(() {
        _currentPosition = newPos;
        _distanceRemaining = dist;
        // Kalau sudah dalam radius 50 meter → dianggap tiba
        _hasArrived = dist < 50;
      });

      // Gambar ulang rute
      _drawRoute();

      // Ikuti posisi user di peta
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(newPos),
      );
    });
  }

  // ── Gambar garis rute dari posisi user ke cabang ───────────────────────────
  void _drawRoute() {
    final origin = _currentPosition ?? widget.userPosition;
    if (origin == null) return;

    final destination = LatLng(widget.branch.latitude, widget.branch.longitude);

    setState(() {
      _polylines.clear();
      // Garis rute (warna biru)
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [origin, destination],
          color: const Color(0xFF3B4BC8),
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );

      // Marker tujuan (cabang)
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: widget.branch.name),
        ),
      );
    });
  }

  // ── Format jarak ke string ─────────────────────────────────────────────────
  String get _distanceText {
    if (_distanceRemaining < 1000) {
      return '${_distanceRemaining.toStringAsFixed(0)} m';
    }
    return '${(_distanceRemaining / 1000).toStringAsFixed(1)} km';
  }

  // ── Estimasi waktu (asumsi 30 km/jam dalam kota) ───────────────────────────
  String get _etaText {
    final minutes = (_distanceRemaining / 1000 / 30 * 60).round();
    if (minutes < 1) return '< 1 mnt';
    return '$minutes mnt';
  }

  // ── Perkiraan waktu tiba ───────────────────────────────────────────────────
  String get _arrivalTime {
    final now = DateTime.now();
    final minutes = (_distanceRemaining / 1000 / 30 * 60).round();
    final arrival = now.add(Duration(minutes: minutes));
    final h = arrival.hour.toString().padLeft(2, '0');
    final m = arrival.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final destination = LatLng(widget.branch.latitude, widget.branch.longitude);

    return Scaffold(
      body: Column(
        children: [
          // ── Peta navigasi (lebih besar) ────────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? destination,
                    zoom: 15,
                    tilt: 45, // sedikit miring biar terasa navigasi
                    bearing: 0,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                ),
                // Tombol kembali
                Positioned(
                  top: 44,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18),
                    ),
                  ),
                ),
                // Tombol zoom
                Positioned(
                  top: 44,
                  right: 12,
                  child: Column(
                    children: [
                      _MapButton(
                        icon: Icons.add,
                        onTap: () => _mapController
                            ?.animateCamera(CameraUpdate.zoomIn()),
                      ),
                      const SizedBox(height: 6),
                      _MapButton(
                        icon: Icons.remove,
                        onTap: () => _mapController
                            ?.animateCamera(CameraUpdate.zoomOut()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Panel bawah ────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Instruksi turn-by-turn (dummy, idealnya dari Maps API)
                  if (!_hasArrived)
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EAFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.turn_right,
                                    color: Color(0xFF3B4BC8), size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Menuju ke tujuan',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.branch.name,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF3B4BC8)),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Info ETA
                  if (!_hasArrived)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _EtaInfo(
                              label: 'Jarak tersisa', value: _distanceText),
                          _EtaInfo(
                              label: 'Estimasi', value: _etaText, center: true),
                          _EtaInfo(
                              label: 'Tiba pukul',
                              value: _arrivalTime,
                              right: true),
                        ],
                      ),
                    ),

                  // Banner sudah tiba
                  if (_hasArrived)
                    Container(
                      margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B4BC8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('🏁', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Anda telah tiba!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                widget.branch.name,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Tombol selesai navigasi
                  if (_hasArrived)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B4BC8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: const Text('Selesai',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget tombol peta ──────────────────────────────────────────────────────
class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

// ── Widget info ETA ─────────────────────────────────────────────────────────
class _EtaInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool center;
  final bool right;

  const _EtaInfo({
    required this.label,
    required this.value,
    this.center = false,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = right
        ? CrossAxisAlignment.end
        : center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
