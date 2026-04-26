import 'package:flutter/material.dart';
import 'detailProduct.dart';
import 'keranjang.dart';
import 'notifikasi.dart';
import 'order_tab.dart';
import 'account_tab.dart';
import '../maps/screens/map_screen.dart';
import '../data/database_helper.dart';
import '../data/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final DatabaseHelper _db = DatabaseHelper();
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final data = await _db.getActiveServices();
    if (mounted) setState(() => _services = data);
  }

  List<ServiceModel> get _filteredServices {
    if (_searchQuery.trim().isEmpty) return _services;
    return _services
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Warna untuk product card
  Color _getCardColor(int index) {
    final colors = [
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.red.shade100,
      Colors.orange.shade100,
      Colors.green.shade100,
      Colors.teal.shade100,
      Colors.indigo.shade100,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          const MapScreen(),
          const OrderTab(),
          const AccountTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 0) _loadServices(); // Refresh saat balik ke home
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E4CB9),
          unselectedItemColor: Colors.grey,
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Order'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 14),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hello, ${SessionManager.currentUserName ?? 'User'}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const KeranjangScreen()));
                      _loadServices();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiScreen()));
                    },
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 12),
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  hintText: 'Cari layanan...',
                  hintStyle: TextStyle(color: Colors.black38),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Product grid
            Expanded(
              child: _services.isEmpty
                  ? const Center(
                      child: Text('Belum ada layanan tersedia.\nAdmin belum menambahkan layanan.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                  : _filteredServices.isEmpty
                      ? const Center(child: Text('Tidak ditemukan.', style: TextStyle(color: Colors.grey)))
                      : RefreshIndicator(
                          onRefresh: _loadServices,
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = _filteredServices[index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DetailProductScreen(service: service),
                                    ),
                                  );
                                  _loadServices();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              color: _getCardColor(index),
                                              child: const Center(
                                                child: Icon(Icons.print, size: 40, color: Colors.white70),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(service.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text('Rp ${service.price}/${service.unit}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}