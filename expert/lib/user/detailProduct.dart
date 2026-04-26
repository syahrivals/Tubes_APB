import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../data/database_helper.dart';
import '../data/models.dart';

class DetailProductScreen extends StatefulWidget {
  final ServiceModel service;

  const DetailProductScreen({super.key, required this.service});

  @override
  State<DetailProductScreen> createState() => _DetailProductScreenState();
}

class _DetailProductScreenState extends State<DetailProductScreen> {
  int _quantity = 1;
  String? _filePath;
  String? _fileName;
  final TextEditingController _sizeController = TextEditingController(text: 'A4');

  int get _totalPrice => widget.service.price * _quantity;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _addToCart() async {
    if (SessionManager.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu.'), backgroundColor: Colors.red),
      );
      return;
    }

    final db = DatabaseHelper();
    await db.insertCartItem(CartItemModel(
      userId: SessionManager.currentUserId!,
      serviceId: widget.service.id!,
      serviceName: widget.service.name,
      quantity: _quantity,
      size: _sizeController.text.trim(),
      filePath: _filePath,
      unitPrice: widget.service.price,
      totalPrice: _totalPrice,
    ));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil ditambahkan ke keranjang!'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E4CB9),
        foregroundColor: Colors.white,
        title: const Text('Detail Produk'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Icon(Icons.print, size: 80, color: Colors.white70)),
            ),
            const SizedBox(height: 16),

            // Nama & Harga
            Text(service.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Rp ${service.price} / ${service.unit}', style: TextStyle(fontSize: 16, color: Colors.grey[700])),

            // Deskripsi
            if (service.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(service.description, style: TextStyle(color: Colors.grey[600])),
            ],

            // Opsi
            if (service.optionsList.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Opsi Tersedia', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: service.optionsList
                    .map((o) => Chip(label: Text(o, style: const TextStyle(fontSize: 12)), backgroundColor: Colors.blue.shade50))
                    .toList(),
              ),
            ],

            const SizedBox(height: 20),

            // Upload File
            const Text('Upload File', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(_fileName != null ? Icons.insert_drive_file : Icons.cloud_upload_outlined,
                        color: const Color(0xFF2E4CB9)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_fileName ?? 'Tap untuk pilih file',
                          style: TextStyle(color: _fileName != null ? Colors.black87 : Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ukuran
            const Text('Ukuran Cetak', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _sizeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quantity
            const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total harga
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Harga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Rp $_totalPrice', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E4CB9))),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Add to Cart
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.shopping_cart),
                label: const Text('TAMBAH KE KERANJANG', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E4CB9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
