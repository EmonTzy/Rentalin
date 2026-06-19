import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/order.dart';

// ═══════════════════════════════════════════════════════════════
// Halaman Detail Pesanan — Dilihat oleh Admin
// Menampilkan seluruh informasi transaksi sewa secara lengkap
// ═══════════════════════════════════════════════════════════════
class AdminOrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const AdminOrderDetailScreen({super.key, required this.order});

  // Helper format rupiah
  String _formatRupiah(double value) {
    final intVal = value.toInt();
    final str = intVal.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buf.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buf.write('.');
        count = 0;
      }
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }

  // Helper format tanggal panjang
  String _formatDateLong(DateTime date) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Helper format tanggal ringkas
  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0D47A1);
    final isDelivery = order.deliveryType.contains('Diantar');

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          // Tombol salin ID pesanan
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Salin ID Pesanan',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('ID pesanan berhasil disalin.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Status Header Card ─────────────────────────────────────────────
          _buildStatusHeader(),
          const SizedBox(height: 16),

          // ── Info Produk ────────────────────────────────────────────────────
          _buildSectionCard(
            title: 'Barang yang Disewa',
            icon: Icons.inventory_2_outlined,
            child: _buildProductInfo(),
          ),
          const SizedBox(height: 12),

          // ── Detail Sewa ────────────────────────────────────────────────────
          _buildSectionCard(
            title: 'Rincian Sewa',
            icon: Icons.event_note_rounded,
            child: _buildRentalInfo(),
          ),
          const SizedBox(height: 12),

          // ── Info Pengiriman ────────────────────────────────────────────────
          _buildSectionCard(
            title: isDelivery ? 'Informasi Pengantaran' : 'Informasi Pengambilan',
            icon: isDelivery ? Icons.local_shipping_outlined : Icons.storefront_rounded,
            child: _buildDeliveryInfo(isDelivery),
          ),
          const SizedBox(height: 12),

          // ── Jaminan KTM ────────────────────────────────────────────────────
          _buildSectionCard(
            title: 'Jaminan KTM Digital',
            icon: Icons.shield_outlined,
            child: _buildGuaranteeInfo(),
          ),
          const SizedBox(height: 12),

          // ── ID Pesanan ──────────────────────────────────────────────────────
          _buildSectionCard(
            title: 'Info Sistem',
            icon: Icons.info_outline_rounded,
            child: _buildSystemInfo(),
          ),
        ],
      ),
    );
  }

  // ── Status Header di Bagian Atas ─────────────────────────────────────────
  Widget _buildStatusHeader() {
    final now = DateTime.now();
    final isOngoing = order.startDate.isBefore(now) && order.endDate.isAfter(now);
    final isUpcoming = order.startDate.isAfter(now);

    String statusText;
    Color statusColor;
    IconData statusIcon;
    Color bgColor;

    if (isOngoing) {
      statusText = 'Sedang Berlangsung';
      statusColor = const Color(0xFFF57C00);
      statusIcon = Icons.access_time_rounded;
      bgColor = const Color(0xFFFFF3E0);
    } else if (isUpcoming) {
      statusText = 'Akan Datang';
      statusColor = const Color(0xFF0D47A1);
      statusIcon = Icons.schedule_rounded;
      bgColor = const Color(0xFFE3F2FD);
    } else {
      statusText = 'Selesai';
      statusColor = const Color(0xFF2E7D32);
      statusIcon = Icons.check_circle_outline_rounded;
      bgColor = const Color(0xFFE8F5E9);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dipesan: ${_formatDateLong(order.orderDate)}',
                  style: TextStyle(fontSize: 12, color: statusColor.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
          Text(
            _formatRupiah(order.totalPrice),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Produk ───────────────────────────────────────────────────────────
  Widget _buildProductInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            order.product.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              width: 80,
              height: 80,
              color: const Color(0xFFF1F5F9),
              child: const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 4),
              _buildChip(
                order.product.category,
                const Color(0xFF0D47A1),
                const Color(0xFFE3F2FD),
              ),
              if (order.selectedSize != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.straighten_rounded, size: 14, color: Color(0xFF555555)),
                    const SizedBox(width: 4),
                    Text(
                      'Ukuran: ${order.selectedSize}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              Text(
                '${_formatRupiah(order.product.pricePerDay)} / hari',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Detail Sewa ───────────────────────────────────────────────────────────
  Widget _buildRentalInfo() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.calendar_today_rounded,
          label: 'Tanggal Mulai',
          value: _formatDateLong(order.startDate),
        ),
        const _Divider(),
        _buildInfoRow(
          icon: Icons.event_available_rounded,
          label: 'Tanggal Selesai',
          value: _formatDateLong(order.endDate),
        ),
        const _Divider(),
        _buildInfoRow(
          icon: Icons.timelapse_rounded,
          label: 'Durasi Sewa',
          value: '${order.durationInDays} hari',
          valueColor: const Color(0xFF0D47A1),
          valueBold: true,
        ),
        const _Divider(),
        _buildInfoRow(
          icon: Icons.payments_outlined,
          label: 'Total Biaya',
          value: _formatRupiah(order.totalPrice),
          valueColor: const Color(0xFF2E7D32),
          valueBold: true,
        ),
        const _Divider(),
        _buildInfoRow(
          icon: Icons.receipt_long_outlined,
          label: 'Harga per Hari',
          value: _formatRupiah(order.product.pricePerDay),
        ),
      ],
    );
  }

  // ── Info Pengiriman ───────────────────────────────────────────────────────
  Widget _buildDeliveryInfo(bool isDelivery) {
    return Column(
      children: [
        _buildInfoRow(
          icon: isDelivery ? Icons.local_shipping_outlined : Icons.storefront_rounded,
          label: 'Metode',
          value: order.deliveryType,
          valueColor: const Color(0xFF0D47A1),
          valueBold: true,
        ),
        if (order.deliveryAddress != null) ...[
          const _Divider(),
          _buildInfoRow(
            icon: Icons.place_outlined,
            label: isDelivery ? 'Alamat Tujuan' : 'Lokasi Ambil',
            value: order.deliveryAddress!,
          ),
        ],
      ],
    );
  }

  // ── Status Jaminan KTM ────────────────────────────────────────────────────
  Widget _buildGuaranteeInfo() {
    final isAccepted = order.isGuaranteeAccepted;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAccepted ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAccepted ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
            color: isAccepted ? const Color(0xFF2E7D32) : Colors.red.shade600,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAccepted ? 'Jaminan KTM Disetujui' : 'Jaminan KTM Belum Disetujui',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isAccepted ? const Color(0xFF2E7D32) : Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isAccepted
                    ? 'Penyewa telah menyetujui syarat jaminan KTM Digital Rentalin.'
                    : 'Penyewa belum menyetujui syarat jaminan.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Info Sistem (ID Pesanan) ───────────────────────────────────────────────
  Widget _buildSystemInfo() {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.tag_rounded,
          label: 'ID Pesanan',
          value: order.id,
          isCode: true,
        ),
        const _Divider(),
        _buildInfoRow(
          icon: Icons.access_time_rounded,
          label: 'Waktu Pesan',
          value:
              '${_formatDateShort(order.orderDate)}, ${order.orderDate.hour.toString().padLeft(2, '0')}:${order.orderDate.minute.toString().padLeft(2, '0')} WIB',
        ),
      ],
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header seksi
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: const Color(0xFF0D47A1)),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 16, thickness: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
    bool isCode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isCode ? 11 : 13,
                fontWeight: valueBold ? FontWeight.bold : FontWeight.w500,
                color: isCode ? Colors.grey.shade600 : (valueColor ?? const Color(0xFF1E1E1E)),
                fontFamily: isCode ? 'monospace' : null,
                height: 1.4,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Divider kecil antar baris info
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 12, thickness: 0.8, color: Colors.grey.shade100);
  }
}
