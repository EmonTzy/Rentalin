import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

// Halaman Konfirmasi Pesanan & Jaminan KTM Digital
class ConfirmationScreen extends StatefulWidget {
  final String deliveryType;
  final String deliveryAddress;

  const ConfirmationScreen({
    super.key,
    required this.deliveryType,
    required this.deliveryAddress,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isAgreementChecked = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  String _orderId = '';

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

  // Aksi Konfirmasi Sewa
  Future<void> _handleConfirmOrder() async {
    if (!_isAgreementChecked) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final order = await AppState.instance.confirmBooking(
        deliveryType: widget.deliveryType,
        deliveryAddress: widget.deliveryAddress,
        isGuaranteeAccepted: _isAgreementChecked,
      );

      setState(() {
        _orderId = order.id;
        _isSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFD0D47A1);
    final appState = AppState.instance;
    final cartItem = appState.cart;

    // Tampilan Sukses Transaksi
    if (_isSuccess) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Centang Hijau
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0x152E7D32),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2E7D32), width: 3),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 56,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Pesanan Berhasil Dibuat!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sewa disetujui instan dengan Jaminan KTM Digital Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 36),
                
                // Ringkasan ID Pemesanan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('ID Transaksi', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                          Text(
                            _orderId,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status Jaminan', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                          Row(
                            children: [
                              Icon(Icons.shield, color: Color(0xFF2E7D32), size: 16),
                              SizedBox(width: 4),
                              Text(
                                'KTM Terverifikasi',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Kembali Ke Beranda',
                  onPressed: () {
                    // Reset stack dan kembali ke home screen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Jika cartItem null (misal saat ditekan konfirmasi, cart dikosongkan), pertahankan info sewa dari widget/state lokal
    if (cartItem == null && !_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Konfirmasi Jaminan',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rincian Pesanan
                  const Text(
                    'Ringkasan Pesanan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                  ),
                  const SizedBox(height: 12),
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
                            const Text('Barang Sewa', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                            Text(
                              cartItem!.product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                            ),
                          ],
                        ),
                        if (cartItem.selectedSize != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ukuran dipilih', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                              Text(
                                cartItem.selectedSize!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Masa Sewa', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                            Text(
                              '${_formatDate(cartItem.startDate)} - ${_formatDate(cartItem.endDate)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Metode Pengiriman', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                            Text(
                              widget.deliveryType,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Alamat/Titik Temu', style: TextStyle(fontSize: 13, color: Color(0xFF555555))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.deliveryAddress,
                              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Kotak Jaminan KTM Digital (Fitur Keamanan Utama)
                  const Text(
                    'Sistem Keamanan Jaminan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade200, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shield_outlined, color: Colors.amber.shade900, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              'JAMINAN KTM DIGITAL',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Colors.amber.shade900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Peminjaman disetujui tanpa deposit uang tunai.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sebagai gantinya, peminjaman ini dijamin penuh menggunakan data KTM Digital Anda. Kerusakan, kehilangan, atau keterlambatan pengembalian barang tanpa konfirmasi akan dikenakan sanksi denda dan penangguhan akademik sesuai aturan kedisiplinan kampus.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Checkbox Persetujuan Syarat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isAgreementChecked,
                        activeColor: themeColor,
                        onChanged: _isLoading 
                            ? null 
                            : (value) {
                                setState(() {
                                  _isAgreementChecked = value ?? false;
                                });
                              },
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Saya menyetujui sanksi kampus yang berlaku jika terjadi kerusakan atau keterlambatan pengembalian barang.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar untuk Total & Konfirmasi Selesai
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
                      'Total Tagihan',
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
                  text: 'Konfirmasi & Sewa Sekarang',
                  isLoading: _isLoading,
                  onPressed: _isAgreementChecked ? _handleConfirmOrder : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
