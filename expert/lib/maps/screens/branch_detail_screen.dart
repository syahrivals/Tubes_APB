import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/branch.dart';
import 'navigation_screen.dart';

class BranchDetailScreen extends StatefulWidget {
  final Branch branch;
  final LatLng? userPosition;

  const BranchDetailScreen({
    super.key,
    required this.branch,
    required this.userPosition,
  });

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  GoogleMapController? _mapController;

  // Marker untuk cabang yang dipilih
  Set<Marker> get _markers {
    return {
      Marker(
        markerId: MarkerId(widget.branch.id),
        position: LatLng(widget.branch.latitude, widget.branch.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: widget.branch.name),
      ),
    };
  }

  // ── Buka Google Maps eksternal untuk navigasi ──────────────────────────────
  Future<void> _openGoogleMapsNavigation() async {
    final lat = widget.branch.latitude;
    final lng = widget.branch.longitude;

    // Kalau ada posisi user, pakai sebagai titik awal
    String url;
    if (widget.userPosition != null) {
      final originLat = widget.userPosition!.latitude;
      final originLng = widget.userPosition!.longitude;
      url =
          'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$lat,$lng&travelmode=driving';
    } else {
      url =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    }

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka Google Maps')),
        );
      }
    }
  }

  // ── Buka layar navigasi in-app ─────────────────────────────────────────────
  void _openInAppNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationScreen(
          branch: widget.branch,
          userPosition: widget.userPosition,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Peta cabang yang dipilih ────────────────────────────────────────
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(branch.latitude, branch.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: _markers,
                  myLocationEnabled: widget.userPosition != null,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                // Tombol back
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
                // Info jarak & waktu estimasi
                if (widget.userPosition != null)
                  Positioned(
                    top: 44,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        '↑ 0.8 km · ~5 mnt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B4BC8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Bottom sheet info cabang ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nama & alamat cabang
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          branch.address,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 10),

                        // Chips: jam, jarak, rating
                        Wrap(
                          spacing: 6,
                          children: [
                            _Chip(
                              label: branch.isOpen
                                  ? 'Buka · ${branch.openHours}'
                                  : 'Tutup',
                              color: branch.isOpen
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFFE4EE),
                              textColor: branch.isOpen
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFC0144A),
                            ),
                            const _Chip(
                              label: '0.8 km',
                              color: Color(0xFFE8EAFF),
                              textColor: Color(0xFF2A38A0),
                            ),
                            _Chip(
                              label: '★ ${branch.rating}',
                              color: const Color(0xFFFEF9C3),
                              textColor: const Color(0xFFA16207),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tombol aksi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Navigasi → buka layar navigasi in-app
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openInAppNavigation,
                            icon: const Icon(Icons.navigation, size: 16),
                            label: const Text('Navigasi',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B4BC8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Pesan → nanti dihubungkan ke fitur temen (shopping)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: hubungkan ke halaman order milik Aliyah
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Menuju halaman pesanan...')),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_outlined,
                                size: 16),
                            label: const Text('Pesan di sini',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1a1a1a),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Daftar layanan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Layanan tersedia',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 6),
                  ...branch.services.map(
                    (svc) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(svc.name, style: const TextStyle(fontSize: 12)),
                          Text(svc.price,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2A38A0))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip kecil ──────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Chip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}
