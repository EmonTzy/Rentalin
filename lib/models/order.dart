import 'product.dart';

// Model data untuk menyimpan riwayat dan rincian pemesanan sewa
class OrderModel {
  final String id;
  final ProductModel product;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String deliveryType; // 'Diantar ke Kos/Kampus' atau 'Ambil Sendiri di Titik Surabaya'
  final String? deliveryAddress; // Alamat tujuan pengantaran (jika diantar) atau keterangan ambil sendiri
  final String? selectedSize; // Ukuran pakaian yang dipilih (jika pakaian formal)
  final DateTime orderDate;
  final bool isGuaranteeAccepted; // Menyatakan apakah jaminan KTM Digital disetujui

  OrderModel({
    required this.id,
    required this.product,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.deliveryType,
    this.deliveryAddress,
    this.selectedSize,
    required this.orderDate,
    required this.isGuaranteeAccepted,
  });

  // Menghitung durasi peminjaman dalam hari
  int get durationInDays {
    final difference = endDate.difference(startDate).inDays;
    return difference <= 0 ? 1 : difference;
  }
}
