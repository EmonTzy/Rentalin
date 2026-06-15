// Model data produk yang disewakan di Rentalin
class ProductModel {
  final String id;
  final String name;
  final String category; // 'Pakaian Formal' atau 'Alat Presentasi/Dokumentasi'
  final String imageUrl;
  final double pricePerDay;
  final String description;
  final bool isAvailable;
  final List<String>? sizeGuide; // Panduan ukuran (khusus Pakaian Formal, misal: S, M, L, XL)
  final List<String>? specs;     // Spesifikasi teknik (khusus Alat Presentasi/Dokumentasi)

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.pricePerDay,
    required this.description,
    required this.isAvailable,
    this.sizeGuide,
    this.specs,
  });

  // Method helper untuk mengecek kategori produk
  bool get isFormalWear => category == 'Pakaian Formal';
  bool get isEquipment => category == 'Alat Presentasi/Dokumentasi';

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      pricePerDay: (data['pricePerDay'] as num).toDouble(),
      description: data['description'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      sizeGuide: data['sizeGuide'] != null ? List<String>.from(data['sizeGuide']) : null,
      specs: data['specs'] != null ? List<String>.from(data['specs']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'description': description,
      'isAvailable': isAvailable,
      if (sizeGuide != null) 'sizeGuide': sizeGuide,
      if (specs != null) 'specs': specs,
    };
  }

  // Salin objek dengan beberapa field baru jika diperlukan
  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    double? pricePerDay,
    String? description,
    bool? isAvailable,
    List<String>? sizeGuide,
    List<String>? specs,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      sizeGuide: sizeGuide ?? this.sizeGuide,
      specs: specs ?? this.specs,
    );
  }
}
