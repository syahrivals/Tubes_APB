import 'package:flutter/material.dart';
import 'dashboard_admin.dart'; 

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  String selectedFilter = 'Semua';
  final List<String> filters = ['Semua', 'Pending', 'Diproses', 'Selesai'];

  // Contoh data pesanan
  List<Map<String, dynamic>> orders = [
    {"id": "#ORD-101", "name": "Andi Supriyadi", "service": "Print A4 BW (50 Lembar)", "status": "Pending"},
    {"id": "#ORD-102", "name": "Siti Rahma", "service": "Jilid Hardcover Skripsi", "status": "Sedang Dicetak"},
    {"id": "#ORD-103", "name": "Budi Santoso", "service": "Cetak Banner 2x1m", "status": "Siap Diambil"},
  ];

  // Fungsi untuk Update Status Pesanan (Tugas Admin Order)
  void _updateStatus(int index, String newStatus) {
    setState(() {
      orders[index]['status'] = newStatus;
    });
    // TODO: Panggil API untuk update status di database server
    print("Status ${orders[index]['id']} diupdate menjadi $newStatus");
  }

  // Helper untuk warna status dropdown
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return const Color(0xFFFFF59D); // Kuning
      case 'Sedang Dicetak': return const Color(0xFFBBDEFB); // Biru muda
      case 'Siap Diambil': return const Color(0xFFC8E6C9); // Hijau muda
      default: return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(title: 'Pesanan Masuk'),
            const SizedBox(height: 16),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: filters.map((filter) {
                  bool isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.text,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFE53935), // Merah seperti di Figma
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (selected) {
                        if (selected) setState(() => selectedFilter = filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),

            // List Pesanan
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order['id']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Dropdown untuk Update Status
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order['status']),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: order['status'],
                                  icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
                                  style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) _updateStatus(index, newValue);
                                  },
                                  items: <String>['Pending', 'Sedang Dicetak', 'Siap Diambil']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Nama: ${order['name']}', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Jasa: ${order['service']}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
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
}