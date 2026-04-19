import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/branch.dart';
import 'branch_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Controller untuk kendalikan kamera peta
  GoogleMapController? _mapController;

  // Posisi user saat ini
  LatLng? _userPosition;

  // Daftar cabang (nanti bisa diganti dari API)
  final List<Branch> _branches = Branch.dummyData();

  // Marker yang tampil di peta
  final Set<Marker> _markers = {};

  // Teks pencarian
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  // ── Ambil lokasi GPS user ──────────────────────────────────────────────────
  Future<void> _getUserLocation() async {
    // Minta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // User menolak permanen → tampilkan pesan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Izin lokasi diperlukan untuk fitur ini')),
        );
      }
      return;
    }

    // Dapatkan posisi sekarang
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
    });

    // Pindahkan kamera ke posisi user
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_userPosition!, 13),
    );

    // Buat marker untuk semua cabang
    _buildMarkers();
  }

  // ── Buat pin/marker di peta untuk tiap cabang ─────────────────────────────
  void _buildMarkers() {
    setState(() {
      _markers.clear();
      for (final branch in _branches) {
        _markers.add(
          Marker(
            markerId: MarkerId(branch.id),
            position: LatLng(branch.latitude, branch.longitude),
            // Pin biru kalau buka, merah kalau tutup
            icon: BitmapDescriptor.defaultMarkerWithHue(
              branch.isOpen
                  ? BitmapDescriptor.hueBlue
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(title: branch.name),
            // Tap marker → buka detail cabang
            onTap: () => _openBranchDetail(branch),
          ),
        );
      }
    });
  }

  // ── Hitung jarak user ke cabang (dalam km) ────────────────────────────────
  String _getDistance(Branch branch) {
    if (_userPosition == null) return '–';
    double distanceInMeters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      branch.latitude,
      branch.longitude,
    );
    double km = distanceInMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  // ── Urutkan cabang dari yang paling dekat ─────────────────────────────────
  List<Branch> get _sortedBranches {
    if (_userPosition == null) return _branches;

    List<Branch> sorted = List.from(_branches);
    sorted.sort((a, b) {
      double distA = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        a.latitude,
        a.longitude,
      );
      double distB = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        b.latitude,
        b.longitude,
      );
      return distA.compareTo(distB);
    });
    return sorted;
  }

  // ── Filter cabang berdasarkan pencarian ───────────────────────────────────
  List<Branch> get _filteredBranches {
    if (_searchQuery.isEmpty) return _sortedBranches;
    return _sortedBranches
        .where((b) => b.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ── Buka halaman detail cabang ────────────────────────────────────────────
  void _openBranchDetail(Branch branch) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BranchDetailScreen(
          branch: branch,
          userPosition: _userPosition,
        ),
      ),
    );
  }

  // ── Tombol kembali ke posisi user ─────────────────────────────────────────
  void _goToUserLocation() {
    if (_userPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_userPosition!, 14),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── Top bar biru ──────────────────────────────────────────────────
          Container(
            color: const Color(0xFF3B4BC8),
            padding: const EdgeInsets.only(
              top: 48,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Surindo Printing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Temukan cabang terdekat',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 10),
                // Search box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama cabang...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Peta Google Maps ──────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    // Default ke Bandung kalau GPS belum ready
                    target: LatLng(-6.9175, 107.6191),
                    zoom: 12,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                // Tombol ke lokasi user (pojok kanan bawah peta)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton.small(
                    onPressed: _goToUserLocation,
                    backgroundColor: Colors.white,
                    child:
                        const Icon(Icons.my_location, color: Color(0xFF3B4BC8)),
                  ),
                ),
              ],
            ),
          ),

          // ── Daftar cabang ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cabang terdekat dari lokasi Anda',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _filteredBranches.length,
              itemBuilder: (context, index) {
                final branch = _filteredBranches[index];
                return _BranchCard(
                  branch: branch,
                  distance: _getDistance(branch),
                  onTap: () => _openBranchDetail(branch),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget card cabang di daftar ──────────────────────────────────────────────
class _BranchCard extends StatelessWidget {
  final Branch branch;
  final String distance;
  final VoidCallback onTap;

  const _BranchCard({
    required this.branch,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Icon toko
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_print_shop,
                    color: Color(0xFF3B4BC8), size: 18),
              ),
              const SizedBox(width: 10),
              // Nama & alamat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branch.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${branch.address} · $distance',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Badge buka/tutup
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: branch.isOpen
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFFE4EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  branch.isOpen ? 'Buka' : 'Tutup',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: branch.isOpen
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFC0144A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
