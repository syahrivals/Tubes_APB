import 'package:flutter/material.dart';
import 'dashboard_admin.dart';
import '../data/database_helper.dart';
import '../data/models.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  String selectedFilter = 'Semua';
  final List<String> filters = ['Semua', 'Pending', 'Sedang Dicetak', 'Siap Diambil'];
  final DatabaseHelper _db = DatabaseHelper();

  List<OrderModel> orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final data = await _db.getAllOrders();
    if (mounted) setState(() { orders = data; _loading = false; });
  }

  List<OrderModel> get filteredOrders {
    if (selectedFilter == 'Semua') return orders;
    return orders.where((o) => o.status == selectedFilter).toList();
  }

  Future<void> _updateStatus(String orderId, String newStatus, int userId) async {
    await _db.updateOrderStatus(orderId, newStatus);

    // Insert notifikasi ke user
    await _db.insertNotification(NotificationModel(
      userId: userId,
      title: 'Status Pesanan Diperbarui',
      message: 'Pesanan $orderId sekarang: $newStatus',
      createdAt: DateTime.now().toIso8601String(),
    ));

    _loadOrders();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFF9800);
      case 'Sedang Dicetak':
        return const Color(0xFF2196F3);
      case 'Siap Diambil':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: 'Pesanan', showBack: true, onBack: () => Navigator.pop(context)),
            const SizedBox(height: 12),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selectedFilter == filter,
                      onSelected: (selected) {
                        if (selected) setState(() => selectedFilter = filter);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selectedFilter == filter ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                      ? const Center(child: Text('Belum ada pesanan.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(order.orderId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order.status).withAlpha(30),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(order.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _getStatusColor(order.status))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Cabang: ${order.branchName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text('Total: Rp ${order.totalPrice}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Ubah Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade300),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: DropdownButton<String>(
                                          value: order.status,
                                          underline: const SizedBox(),
                                          icon: const Icon(Icons.arrow_drop_down, size: 18),
                                          style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) _updateStatus(order.orderId, newValue, order.userId);
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
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}