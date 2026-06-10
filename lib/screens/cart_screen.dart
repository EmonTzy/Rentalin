import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/custom_button.dart';
import 'confirmation_screen.dart';

// Halaman Keranjang & Checkout
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _deliveryType = 'Diantar ke Kos/Kampus'; // Default

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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

  // Format tanggal ringkas
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Aksi menuju halaman konfirmasi jaminan
  void _navigateToConfirmation() {
    if (_deliveryType == 'Diantar ke Kos/Kampus') {
      if (!_formKey.currentState!.validate()) return;
    }

    final cartItem = AppState.instance.cart;
    if (cartItem == null) return;

    final deliveryAddress = _deliveryType == 'Diantar ke Kos/Kampus' 
        ? _addressController.text.trim()
        : 'Ambil Sendiri di Kantor Rentalin Surabaya (Samping Gerbang Utama ITS)';

    // Navigasi ke halaman Konfirmasi Keamanan Jaminan KTM Digital
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          deliveryType: _deliveryType,
          deliveryAddress: deliveryAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFD0D47A1);
    final appState = AppState.instance;
    final cartItem = appState.cart;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: cartItem == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Keranjang Belanja Kosong',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih produk di katalog untuk mulai menyewa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Lihat Katalog',
                      width: 200,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Card
                          const Text(
                            'Detail Barang Sewa',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar Mini
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.network(
                                      cartItem.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.grey.shade100,
                                        child: const Icon(Icons.inventory, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Info Detail
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (cartItem.selectedSize != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Ukuran: ${cartItem.selectedSize}',
                                          style: TextStyle(color: themeColor, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Text(
                                        '${_formatRupiah(cartItem.product.pricePerDay)} / hari',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                // Tombol Hapus
                                IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                                  onPressed: () {
                                    appState.removeFromCart();
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Renting Duration & Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Tanggal Peminjaman', style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
                                    Text(
                                      '${_formatDate(cartItem.startDate)} - ${_formatDate(cartItem.endDate)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Durasi Sewa', style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
                                    Text(
                                      '${cartItem.durationInDays} hari',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Delivery Method Selection
                          const Text(
                            'Pilihan Pengiriman',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                          const SizedBox(height: 12),
                          // Radio Option 1: Diantar
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _deliveryType = 'Diantar ke Kos/Kampus';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _deliveryType == 'Diantar ke Kos/Kampus' ? themeColor : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'Diantar ke Kos/Kampus',
                                    groupValue: _deliveryType,
                                    activeColor: themeColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _deliveryType = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.local_shipping_outlined, color: Color(0xFF555555)),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Diantar ke Kos/Kampus',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Radio Option 2: Ambil Sendiri
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _deliveryType = 'Ambil Sendiri di Titik Surabaya';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _deliveryType == 'Ambil Sendiri di Titik Surabaya' ? themeColor : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'Ambil Sendiri di Titik Surabaya',
                                    groupValue: _deliveryType,
                                    activeColor: themeColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _deliveryType = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.storefront_rounded, color: Color(0xFF555555)),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Ambil Sendiri di Titik Surabaya',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Area Detail Pengantaran
                          if (_deliveryType == 'Diantar ke Kos/Kampus') ...[
                            const Text(
                              'Alamat Pengantaran',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama kos/jalan, nomor rumah, dan instruksi pengiriman...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: themeColor, width: 2),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Alamat pengiriman tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            // Info statis ambil sendiri (sesuai request, tanpa dropdown)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline_rounded, color: themeColor, size: 22),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lokasi Pengambilan',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Kantor Rentalin Surabaya (Samping Gerbang Utama ITS, Jl. Raya Manyar No. 45). Buka setiap hari pukul 07.00 - 20.00 WIB.',
                                          style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF424242)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Bottom Summary & Action
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                            Text(
                              _formatRupiah(cartItem.totalPrice),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Lanjutkan Ke Konfirmasi',
                          onPressed: _navigateToConfirmation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
