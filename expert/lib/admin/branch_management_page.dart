import 'package:flutter/material.dart';
import 'dashboard_admin.dart'; 

class BranchManagementPage extends StatefulWidget {
  const BranchManagementPage({super.key});

  @override
  State<BranchManagementPage> createState() => _BranchManagementPageState();
}

class _BranchManagementPageState extends State<BranchManagementPage> {
  // Contoh data statis, nanti ganti dengan fetch dari API/Database
  final List<Map<String, dynamic>> branches = [
    {"name": "Surindo Printing Pusat", "address": "Jl. Sudirman No. 123, Jakarta Pusat"},
    {"name": "Surindo Printing Cabang Selatan", "address": "Jl. TB Simatupang No. 45, Jakarta Selatan"},
    {"name": "Surindo Printing Cabang Timur", "address": "Jl. Swadaya No. 15, Jakarta Timur"},
    {"name": "Surindo Printing Cabang Utara", "address": "Jl. Tanjung Priok No. 30, Jakarta Utara"},
  ];

  // Fungsi untuk tugas Admin Branch (Ambil Koordinat GPS & Create)
  void _tambahCabangDenganGPS() {
    // TODO: Gunakan package seperti 'geolocator' untuk mengambil latitude & longitude
    // TODO: Buka form/modal untuk input nama cabang baru
    print("Membuka form tambah cabang & mengambil lokasi GPS saat ini...");
  }

  void _editCabang(int index) {
    // TODO: Buka form edit untuk cabang yang dipilih
    print("Edit cabang: ${branches[index]['name']}");
  }

  void _hapusCabang(int index) {
    // TODO: Panggil API delete
    print("Hapus cabang: ${branches[index]['name']}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Manajemen Cabang',
              showBack: true,
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            
            // Search Bar & Tambah Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari cabang...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _tambahCabangDenganGPS,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text(
                      '+ Tambah',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${branches.length} Cabang Tersedia',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // List Cabang
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 32, color: Colors.black87),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch['name']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                branch['address']!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _actionButton('Edit', const Color(0xFFFFF9C4), const Color(0xFFF57F17), () => _editCabang(index)),
                                  const SizedBox(width: 12),
                                  _actionButton('Hapus', const Color(0xFFFFCDD2), const Color(0xFFC62828), () => _hapusCabang(index)),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget custom untuk tombol Edit & Hapus
  Widget _actionButton(String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}