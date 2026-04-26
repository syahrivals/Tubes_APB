import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/branch.dart';
import 'branch_detail_screen.dart';
import '../../data/database_helper.dart';
import '../../data/models.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _userPosition;
  List<BranchModel> _branches = [];
  final Set<Marker> _markers = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final branches = await db.getAllBranches();
    if (mounted) {
      setState(() => _branches = branches);
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi diperlukan untuk fitur ini')),
        );
      }
      _buildMarkers();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_userPosition!, 13),
    );
    _buildMarkers();
  }

  void _buildMarkers() {
    setState(() {
      _markers.clear();
      for (final branch in _branches) {
        if (branch.latitude == 0 && branch.longitude == 0) continue;
        _markers.add(
          Marker(
            markerId: MarkerId(branch.id.toString()),
            position: LatLng(branch.latitude, branch.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              branch.isOpen ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(title: branch.name),
            onTap: () => _openBranchDetail(branch),
          ),
        );
      }
    });
  }

  String _getDistance(BranchModel branch) {
    if (_userPosition == null) return '–';
    if (branch.latitude == 0 && branch.longitude == 0) return '–';
    double distanceInMeters = Geolocator.distanceBetween(
      _userPosition!.latitude, _userPosition!.longitude,
      branch.latitude, branch.longitude,
    );
    double km = distanceInMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  List<BranchModel> get _sortedBranches {
    if (_userPosition == null) return _filteredBySearch;
    List<BranchModel> sorted = List.from(_filteredBySearch);
    sorted.sort((a, b) {
      if (a.latitude == 0 || b.latitude == 0) return 0;
      double distA = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, a.latitude, a.longitude);
      double distB = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, b.latitude, b.longitude);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  List<BranchModel> get _filteredBySearch {
    if (_searchQuery.isEmpty) return _branches;
    return _branches.where((b) => b.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _openBranchDetail(BranchModel branch) {
    // Convert to old Branch model for compatibility with detail/navigation screens
    final oldBranch = Branch(
      id: branch.id.toString(),
      name: branch.name,
      address: branch.address,
      latitude: branch.latitude,
      longitude: branch.longitude,
      isOpen: branch.isOpen,
      openHours: branch.openHours,
      rating: branch.rating,
      services: [], // Will be loaded in detail screen
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BranchDetailScreen(
          branch: oldBranch,
          userPosition: _userPosition,
        ),
      ),
    );
  }

  void _goToUserLocation() {
    if (_userPosition != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_userPosition!, 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top bar
          Container(
            color: const Color(0xFF3B4BC8),
            padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Surindo Printing', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('Temukan cabang terdekat', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama cabang...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Google Maps
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(-6.9175, 107.6191), zoom: 12),
                  onMapCreated: (controller) => _mapController = controller,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  bottom: 10, right: 10,
                  child: FloatingActionButton.small(
                    onPressed: _goToUserLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Color(0xFF3B4BC8)),
                  ),
                ),
              ],
            ),
          ),

          // Branch list
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _branches.isEmpty ? 'Belum ada cabang' : 'Cabang terdekat dari lokasi Anda',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ),
          Expanded(
            child: _sortedBranches.isEmpty
                ? const Center(child: Text('Belum ada cabang. Admin belum menambahkan.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _sortedBranches.length,
                    itemBuilder: (context, index) {
                      final branch = _sortedBranches[index];
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

class _BranchCard extends StatelessWidget {
  final BranchModel branch;
  final String distance;
  final VoidCallback onTap;

  const _BranchCard({required this.branch, required this.distance, required this.onTap});

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
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFFE8EAFF), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_print_shop, color: Color(0xFF3B4BC8), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(branch.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('${branch.address} · $distance', style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: branch.isOpen ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4EE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  branch.isOpen ? 'Buka' : 'Tutup',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: branch.isOpen ? const Color(0xFF16A34A) : const Color(0xFFC0144A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
