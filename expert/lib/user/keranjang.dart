import 'package:flutter/material.dart';
import 'pilih_cabang.dart';
import '../data/database_helper.dart';
import '../data/models.dart';

class KeranjangScreen extends StatefulWidget {
  const KeranjangScreen({super.key});

  @override
  State<KeranjangScreen> createState() => _KeranjangScreenState();
}

class _KeranjangScreenState extends State<KeranjangScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<CartItemModel> _items = [];
  final Set<int> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (SessionManager.currentUserId == null) return;
    final items = await _db.getCartItems(SessionManager.currentUserId!);
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  int get _totalHarga {
    return _items
        .where((item) => _selectedIds.contains(item.id))
        .fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _deleteItem(CartItemModel item) async {
    await _db.deleteCartItem(item.id!);
    _selectedIds.remove(item.id);
    _loadCart();
  }

  void _checkout() {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 item untuk checkout.'), backgroundColor: Colors.red),
      );
      return;
    }

    final selectedItems = _items.where((item) => _selectedIds.contains(item.id)).toList();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PilihCabangScreen(
        cartItems: selectedItems,
        totalHarga: _totalHarga,
      )),
    ).then((_) => _loadCart()); // Refresh setelah checkout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E4CB9),
        foregroundColor: Colors.white,
        title: const Text('Keranjang'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Keranjang kosong.\nTambahkan layanan dari dashboard.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isSelected = _selectedIds.contains(item.id);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFF2E4CB9) : Colors.grey.shade200, width: isSelected ? 2 : 1),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedIds.add(item.id!);
                                      } else {
                                        _selectedIds.remove(item.id!);
                                      }
                                    });
                                  },
                                  activeColor: const Color(0xFF2E4CB9),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text('Ukuran: ${item.size}  ·  Qty: ${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      if (item.filePath != null)
                                        Text('File: ${item.filePath!.split('/').last}', style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('Rp ${item.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E4CB9))),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteItem(item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Bottom bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -4))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${_selectedIds.length} item dipilih', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Text('Rp $_totalHarga', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E4CB9))),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E4CB9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
