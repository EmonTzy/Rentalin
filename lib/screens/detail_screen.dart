import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/app_state.dart';
import '../widgets/custom_button.dart';
import 'cart_screen.dart';

// Halaman Detail Produk
class DetailScreen extends StatefulWidget {
  final ProductModel product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _selectedSize;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1)); // Default 1 hari sewa

  @override
  void initState() {
    super.initState();
    // Default pilih ukuran pertama jika kategori pakaian formal
    if (widget.product.isFormalWear && widget.product.sizeGuide != null && widget.product.sizeGuide!.isNotEmpty) {
      // Ambil kode ukuran depan saja, misal 'S' dari 'S (Lebar Dada...)'
      _selectedSize = widget.product.sizeGuide!.first.split(' ')[0];
    }
  }

  // Fungsi memanggil Date Range Picker bawaan Flutter
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFD0D47A1), // Header & Selected range
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  int get _durationInDays {
    final diff = _endDate.difference(_startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get _totalPrice => widget.product.pricePerDay * _durationInDays;

  // Helper formatting tanggal
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Helper format rupiah
  String _formatRupiah(double value) {
    final intVal = value.toInt();
    final buffer = StringBuffer();
    final strVal = intVal.toString();
    
    int count = 0;
    for (int i = strVal.length - 1; i >= 0; i--) {
      buffer.write(strVal[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  // Aksi Tambah Ke Keranjang & Navigasi Checkout
  void _handleAddToCart() {
    if (widget.product.isFormalWear && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih ukuran jas/kebaya terlebih dahulu!')),
      );
      return;
    }

    // Tambahkan data ke keranjang belanja
    AppState.instance.addToCart(
      widget.product,
      _selectedSize,
      _startDate,
      _endDate,
    );

    // Buka Keranjang / Checkout secara langsung (Booking cepat < 3 menit)
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFD0D47A1);
    final product = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bagian Scroll Detail
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Galeri Gambar Produk
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              product.isFormalWear ? Icons.dry_cleaning : Icons.slideshow,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Nama & Kategori & Ketersediaan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori & Badge Ketersediaan
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.category.toUpperCase(),
                              style: TextStyle(
                                color: themeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.isAvailable
                                    ? const Color(0x202E7D32)
                                    : const Color(0x20C62828),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.isAvailable ? 'Tersedia' : 'Sedang Disewa',
                                style: TextStyle(
                                  color: product.isAvailable
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFC62828),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Nama Produk
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Harga per hari
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _formatRupiah(product.pricePerDay),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: themeColor,
                              ),
                            ),
                            Text(
                              ' / hari',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1),

                        // Deskripsi Barang
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Fitur Spesifik Kategori (Pakaian Formal -> Size Guide, Elektronik -> Spesifikasi)
                        if (product.isFormalWear && product.sizeGuide != null) ...[
                          const Text(
                            'Pilih Ukuran (Jas / Kebaya)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Chips Ukuran Pakaian
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: product.sizeGuide!.map((sizeText) {
                              final sizeCode = sizeText.split(' ')[0];
                              final isSelected = _selectedSize == sizeCode;

                              return ChoiceChip(
                                label: Text(
                                  sizeText,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: themeColor,
                                backgroundColor: const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected ? themeColor : Colors.grey.shade200,
                                  ),
                                ),
                                showCheckmark: false,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedSize = sizeCode;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ] else if (product.isEquipment && product.specs != null) ...[
                          const Text(
                            'Spesifikasi Alat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Daftar bullet spesifikasi
                          ...product.specs!.map((spec) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: CircleAvatar(
                                        radius: 3.5,
                                        backgroundColor: themeColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        spec,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],

                        const Divider(height: 40, thickness: 1),

                        // Input Sistem Kalender Booking
                        const Text(
                          'Pilih Tanggal Peminjaman',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Box pemilih kalender
                        InkWell(
                          onTap: () => _selectDateRange(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, color: themeColor),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_formatDate(_startDate)}  s/d  ${_formatDate(_endDate)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E1E1E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Durasi Sewa: $_durationInDays hari',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Booking Summary Bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Biaya Sewa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(_totalPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      text: 'Sewa Sekarang',
                      onPressed: product.isAvailable ? _handleAddToCart : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
