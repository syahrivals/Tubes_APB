import 'package:flutter/material.dart';
import 'catalog_service.dart';
import 'branch_management_page.dart'; // Pastikan file ini sudah kamu buat
import 'order_management_page.dart';  // Pastikan file ini sudah kamu buat

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int currentIndex = 0;

  // Daftar halaman untuk navigasi bawah (Bottom Navigation)
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Index 0: Tampilan Katalog (Layanan & Cabang)
      _buildKatalogView(),
      // Index 1: Tampilan Pesanan
      const OrderManagementPage(),
      // Index 2: Tampilan Profil (Placeholder sementara)
      const Center(child: Text('Halaman Profil Belum Dibuat')),
    ];
  }

  // Widget khusus untuk tampilan Katalog (Beranda awal)
  Widget _buildKatalogView() {
    return SafeArea(
      child: Column(
        children: [
          const CustomHeader(title: 'Katalog'),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                MenuCard(
                  icon: Icons.design_services_outlined,
                  title: 'Layanan',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CatalogServicePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                MenuCard(
                  icon: Icons.location_on_outlined,
                  title: 'Cabang',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BranchManagementPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      // Body akan berubah sesuai dengan tab navigasi bawah yang diklik
      body: _pages[currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF2848C7);
  static const primarySoft = Color(0xFFDCE3FF);
  static const border = Color(0xFF9CB0FF);
  static const card = Color(0xFFF2F4FB);
  static const text = Color(0xFF3B3B45);
}

class CustomHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            )
          else
            const SizedBox(width: 34),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.text),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.grid_view_rounded, 'Katalog'),
      (Icons.check_box_outlined, 'Pesanan'),
      (Icons.person_outline, 'Profil'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFD8DFFD),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;
          return InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFB7C5FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(items[index].$1, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[index].$2,
                    style: const TextStyle(fontSize: 12, color: AppColors.text),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}