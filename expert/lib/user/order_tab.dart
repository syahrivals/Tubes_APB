import 'package:flutter/material.dart';
import 'order_detail.dart';
import '../data/database_helper.dart';
import '../data/models.dart';

class OrderTab extends StatefulWidget {
  const OrderTab({super.key});

  @override
  State<OrderTab> createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  final DatabaseHelper _db = DatabaseHelper();
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (SessionManager.currentUserId == null) return;
    final data = await _db.getOrdersByUser(SessionManager.currentUserId!);
    if (mounted) setState(() { _orders = data; _loading = false; });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return const Color(0xFFFF9800);
      case 'Sedang Dicetak': return const Color(0xFF2196F3);
      case 'Siap Diambil': return const Color(0xFF4CAF50);
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2E4CB9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Text('Pesanan Saya', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                    ? const Center(child: Text('Belum ada pesanan.\nCheckout dari keranjang untuk membuat pesanan.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                                  const SizedBox(height: 6),
                                  Text('Cabang: ${order.branchName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  Text('Total: Rp ${order.totalPrice}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await Navigator.push(context, MaterialPageRoute(
                                          builder: (_) => OrderDetailScreen(order: order),
                                        ));
                                        _loadOrders();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.grey.shade300),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Detail', style: TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
