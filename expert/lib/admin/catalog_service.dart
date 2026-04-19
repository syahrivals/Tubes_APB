import 'package:flutter/material.dart';
import 'dashboard_admin.dart';

class CatalogServicePage extends StatefulWidget {
  const CatalogServicePage({super.key});

  @override
  State<CatalogServicePage> createState() => _CatalogServicePageState();
}

class _CatalogServicePageState extends State<CatalogServicePage> {
  int currentIndex = 0;
  final TextEditingController searchController = TextEditingController();

  final List<ServiceItem> allServices = [
    ServiceItem(
      id: 1,
      name: 'Print Dokumen A4',
      price: 500,
      unit: 'lembar',
      options: ['BW', 'Berwarna'],
      description:
          'Layanan cetak dokumen ukuran A4 tersedia dalam mode BW dan berwarna menggunakan printer laser',
      isActive: true,
      icon: Icons.print_outlined,
    ),
    ServiceItem(
      id: 2,
      name: 'Fotocopy',
      price: 500,
      unit: 'lembar',
      options: ['BW'],
      description: 'Layanan fotocopy cepat untuk dokumen hitam putih',
      isActive: true,
      icon: Icons.copy_all_outlined,
    ),
    ServiceItem(
      id: 3,
      name: 'Cetak Foto',
      price: 500,
      unit: 'lembar',
      options: ['Glossy', 'Matte'],
      description: 'Cetak foto dengan kualitas warna tajam',
      isActive: true,
      icon: Icons.image_outlined,
    ),
    ServiceItem(
      id: 4,
      name: 'Cetak Spanduk',
      price: 500,
      unit: 'lembar',
      options: ['Outdoor'],
      description: 'Layanan cetak spanduk untuk kebutuhan promosi',
      isActive: false,
      icon: Icons.format_paint_outlined,
    ),
  ];

  String query = '';

  List<ServiceItem> get filteredServices {
    if (query.trim().isEmpty) return allServices;
    return allServices
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> openAddForm() async {
    final result = await Navigator.push<ServiceItem>(
      context,
      MaterialPageRoute(builder: (_) => const ServiceFormPage()),
    );

    if (result != null) {
      setState(() {
        allServices.insert(0, result);
      });
    }
  }

  Future<void> openEditForm(ServiceItem item) async {
    final result = await Navigator.push<ServiceItem>(
      context,
      MaterialPageRoute(builder: (_) => ServiceFormPage(service: item)),
    );

    if (result != null) {
      final index = allServices.indexWhere((e) => e.id == item.id);
      if (index != -1) {
        setState(() {
          allServices[index] = result;
        });
      }
    }
  }

  Future<void> deleteService(ServiceItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Layanan'),
        content: Text('Yakin ingin menghapus ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF7F7F),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        allServices.removeWhere((e) => e.id == item.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: 'Layanan',
              showBack: true,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {
                                query = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari layanan...',
                              filled: true,
                              fillColor: AppColors.card,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: openAddForm,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('+ Tambah'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${filteredServices.length} Layanan Tersedia',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C7C88),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...filteredServices.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ServiceCard(
                          item: item,
                          onEdit: () => openEditForm(item),
                          onDelete: () => deleteService(item),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

class ServiceItem {
  int id;
  String name;
  int price;
  String unit;
  List<String> options;
  String description;
  bool isActive;
  IconData icon;

  ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.options,
    required this.description,
    required this.isActive,
    required this.icon,
  });
}

class ServiceFormPage extends StatefulWidget {
  final ServiceItem? service;

  const ServiceFormPage({super.key, this.service});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController unitController;
  late final TextEditingController descriptionController;
  final TextEditingController optionController = TextEditingController();

  late bool isActive;
  late List<String> options;

  bool get isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.service?.name ?? '');
    priceController = TextEditingController(
      text: widget.service?.price.toString() ?? '',
    );
    unitController = TextEditingController(text: widget.service?.unit ?? '');
    descriptionController = TextEditingController(
      text: widget.service?.description ?? '',
    );
    isActive = widget.service?.isActive ?? true;
    options = List<String>.from(widget.service?.options ?? []);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    unitController.dispose();
    descriptionController.dispose();
    optionController.dispose();
    super.dispose();
  }

  void addOption() {
    final value = optionController.text.trim();
    if (value.isEmpty) return;

    setState(() {
      options.add(value);
      optionController.clear();
    });
  }

  void saveForm() {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        unitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi data wajib terlebih dahulu.'),
        ),
      );
      return;
    }

    final item = ServiceItem(
      id: widget.service?.id ?? DateTime.now().millisecondsSinceEpoch,
      name: nameController.text.trim(),
      price: int.tryParse(priceController.text.trim()) ?? 0,
      unit: unitController.text.trim(),
      options: options,
      description: descriptionController.text.trim(),
      isActive: isActive,
      icon: widget.service?.icon ?? Icons.print_outlined,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomHeader(
                title: isEdit ? 'Edit Layanan' : 'Tambah Layanan',
                showBack: true,
                onBack: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InputLabel(label: 'Nama Layanan*'),
                    AppTextField(
                      controller: nameController,
                      hintText: 'Masukkan nama layanan',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const InputLabel(label: 'Harga*'),
                              AppTextField(
                                controller: priceController,
                                hintText: '500',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const InputLabel(label: 'Satuan*'),
                              AppTextField(
                                controller: unitController,
                                hintText: 'Lembar',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const InputLabel(label: 'Opsi Tambahan'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...options.map(
                          (option) => OptionChip(
                            label: option,
                            filled: true,
                            onTap: () {
                              setState(() {
                                options.remove(option);
                              });
                            },
                          ),
                        ),
                        OptionChip(
                          label: '+ Tambah',
                          filled: false,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => Padding(
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 20,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                      20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Tambah Opsi',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AppTextField(
                                      controller: optionController,
                                      hintText: 'Contoh: BW / Berwarna',
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: () {
                                          addOption();
                                          Navigator.pop(context);
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                        ),
                                        child: const Text('Simpan Opsi'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const InputLabel(label: 'Deskripsi Layanan'),
                    AppTextField(
                      controller: descriptionController,
                      hintText: 'Masukkan deskripsi layanan',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    const InputLabel(label: 'Status'),
                    Row(
                      children: [
                        Expanded(
                          child: StatusButton(
                            label: 'Aktif',
                            selected: isActive,
                            onTap: () {
                              setState(() {
                                isActive = true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: StatusButton(
                            label: 'Nonaktif',
                            selected: !isActive,
                            onTap: () {
                              setState(() {
                                isActive = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        SizedBox(
                          width: 92,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: saveForm,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Simpan Layanan',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, size: 28, color: AppColors.text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    StatusBadge(isActive: item.isActive),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp. ${item.price} / ${item.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7C7C88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SmallActionButton(
                      label: 'Edit',
                      backgroundColor: const Color(0xFFFFE29C),
                      textColor: const Color(0xFF9B6A00),
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),
                    SmallActionButton(
                      label: 'Hapus',
                      backgroundColor: const Color(0xFFFFC0C0),
                      textColor: const Color(0xFFC62828),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmallActionButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const SmallActionButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final bool isActive;

  const StatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFCFF6C7) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          color: isActive ? const Color(0xFF277A1E) : const Color(0xFF666666),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class InputLabel extends StatelessWidget {
  final String label;

  const InputLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class OptionChip extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const OptionChip({
    super.key,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF6B87F5) : AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: filled ? const Color(0xFF6B87F5) : AppColors.border,
          ),
          boxShadow: filled
              ? const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          filled ? '$label X' : label,
          style: TextStyle(
            color: filled ? Colors.white : const Color(0xFF7C7C88),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class StatusButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const StatusButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: selected
          ? FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
