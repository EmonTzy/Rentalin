import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      product: ProductModel.fromFirestore(
        Map<String, dynamic>.from(data['product']),
        data['productId'] ?? '',
      ),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      deliveryType: data['deliveryType'] ?? '',
      deliveryAddress: data['deliveryAddress'],
      selectedSize: data['selectedSize'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      isGuaranteeAccepted: data['isGuaranteeAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore(String userId) {
    return {
      'userId': userId,
      'productId': product.id,
      'product': product.toFirestore(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalPrice': totalPrice,
      'deliveryType': deliveryType,
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (selectedSize != null) 'selectedSize': selectedSize,
      'orderDate': Timestamp.fromDate(orderDate),
      'isGuaranteeAccepted': isGuaranteeAccepted,
    };
  }

  // Menghitung durasi peminjaman dalam hari
  int get durationInDays {
    final difference = endDate.difference(startDate).inDays;
    return difference <= 0 ? 1 : difference;
  }
}
