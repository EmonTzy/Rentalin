import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import 'mock_auth_service.dart';
import 'firestore_service.dart';

// Item di dalam keranjang belanja
class CartItem {
  final ProductModel product;
  final String? selectedSize;
  final DateTime startDate;
  final DateTime endDate;

  CartItem({
    required this.product,
    this.selectedSize,
    required this.startDate,
    required this.endDate,
  });

  int get durationInDays {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get totalPrice => product.pricePerDay * durationInDays;
}

// Produk default yang di-seed ke Firestore saat pertama kali dijalankan
final _defaultProducts = [
  ProductModel(
    id: 'prod_jas_premium',
    name: 'Jas Set Lengkap (Premium)',
    category: 'Pakaian Formal',
    imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&q=80&w=600',
    pricePerDay: 50000.0,
    description:
        'Setelan jas premium hitam formal lengkap untuk kebutuhan sidang skripsi, yudisium, atau wawancara kerja. Paket sewa sudah termasuk: Jas luar, celana bahan hitam, kemeja putih lengan panjang, dasi hitam, dan hanger pelindung.',
    isAvailable: true,
    sizeGuide: ['S (Lebar Dada 48cm)', 'M (Lebar Dada 50cm)', 'L (Lebar Dada 52cm)', 'XL (Lebar Dada 54cm)', 'XXL (Lebar Dada 56cm)'],
  ),
  ProductModel(
    id: 'prod_kebaya_modern',
    name: 'Kebaya Modern Brokat',
    category: 'Pakaian Formal',
    imageUrl: 'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?auto=format&fit=crop&q=80&w=600',
    pricePerDay: 65000.0,
    description:
        'Kebaya modern dengan detail brokat halus dan bawahan rok batik Surabaya yang elegan. Sangat cocok untuk mahasiswi yang akan melaksanakan wisuda, yudisium, atau acara formal kampus lainnya. Nyaman digunakan seharian.',
    isAvailable: true,
    sizeGuide: ['S (Lingkar Dada 88cm)', 'M (Lingkar Dada 92cm)', 'L (Lingkar Dada 96cm)', 'XL (Lingkar Dada 100cm)'],
  ),
  ProductModel(
    id: 'prod_blazer_casual',
    name: 'Blazer Hitam Slimfit',
    category: 'Pakaian Formal',
    imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=600',
    pricePerDay: 35000.0,
    description:
        'Blazer hitam dengan potongan slimfit semi-formal yang fleksibel. Cocok bagi mahasiswa yang ingin tampil rapi namun tetap kasual saat presentasi proyek kuliah atau seminar hasil.',
    isAvailable: true,
    sizeGuide: ['S', 'M', 'L', 'XL'],
  ),
  ProductModel(
    id: 'prod_pointer_logi',
    name: 'Laser Pointer Logitech Spotlight',
    category: 'Alat Presentasi/Dokumentasi',
    imageUrl: 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?auto=format&fit=crop&q=80&w=600',
    pricePerDay: 15000.0,
    description:
        'Pointer presentasi profesional tercanggih dari Logitech. Membantu Anda menyoroti (highlight) dan memperbesar (magnify) area presentasi di layar proyektor dengan sangat jelas. Sidang skripsi dijamin lebih meyakinkan!',
    isAvailable: true,
    specs: [
      'Konektivitas: Bluetooth Smart dan 2.4GHz Wireless Connection',
      'Jangkauan Operasional: Hingga 30 meter',
      'Fitur Utama: Highlight, Magnify, Kontrol Volume, dan Timer Pengingat',
      'Daya: Baterai isi ulang cepat (charger USB tipe C)',
    ],
  ),
  ProductModel(
    id: 'prod_tripod_hp',
    name: 'Tripod HP & Kamera Takara 1.5m',
    category: 'Alat Presentasi/Dokumentasi',
    imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=600',
    pricePerDay: 10000.0,
    description:
        'Tripod ringan dengan dudukan HP (phone holder) dan sekrup universal untuk kamera mirrorless. Sangat berguna untuk dokumentasi sidang, perekaman video ujian mengajar, atau pembuatan konten presentasi tugas akhir.',
    isAvailable: true,
    specs: [
      'Tinggi Maksimum: 150 cm',
      'Tinggi Minimum: 45 cm (sangat ringkas dibawa)',
      'Bahan: Aluminium Alloy ringan kokoh',
      'Kapasitas Beban Maksimal: 2 kg',
      'Sudah termasuk tas tripod dan U-holder HP premium',
    ],
  ),
  ProductModel(
    id: 'prod_ring_light',
    name: 'Ring Light LED + Stand 2 Meter',
    category: 'Alat Presentasi/Dokumentasi',
    imageUrl: 'https://images.unsplash.com/photo-1619441207978-3d326c46e2c9?auto=format&fit=crop&q=80&w=600',
    pricePerDay: 20000.0,
    description:
        'Lampu penerangan berbentuk ring LED lengkap dengan stand setinggi 2 meter untuk hasil pencahayaan video yang profesional. Sangat disarankan untuk video conference sidang online di kos agar wajah terlihat terang dan jelas.',
    isAvailable: true,
    specs: [
      'Diameter Ring: 26 cm / 10 inci',
      'Mode Cahaya: 3 Warna (Putih Dingin, Kuning Hangat, Kuning Alami)',
      'Tingkat Kecerahan: 10 level intensitas cahaya',
      'Tinggi Stand: Adjustable dari 70cm hingga 200cm',
      'Sumber Daya: Kabel USB (bisa dicolok ke charger HP atau powerbank)',
    ],
  ),
];

// Global State Provider menggunakan ChangeNotifier bawaan Flutter
class AppState extends ChangeNotifier {
  // Singleton pattern agar state dapat diakses secara global
  static final AppState instance = AppState._internal();
  AppState._internal() {
    _initialize();
  }

  final MockAuthService _authService = MockAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _products = [];
  CartItem? _cart;
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  StreamSubscription<List<ProductModel>>? _productsSubscription;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  // Getters
  UserModel? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;
  List<ProductModel> get products => _products;
  CartItem? get cart => _cart;
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  // Pencarian & Filter
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Filtered Products
  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Semua' || product.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> _initialize() async {
    await _firestoreService.seedProductsIfEmpty(_defaultProducts);

    _productsSubscription = _firestoreService.productsStream().listen((products) {
      _products = products;
      notifyListeners();
    });
  }

  void _subscribeToOrders(String userId) {
    _ordersSubscription?.cancel();
    _ordersSubscription = _firestoreService.ordersStream(userId).listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  // ── Authentication Actions ─────────────────────────────────────────────────

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);
      await _firestoreService.saveUser(user);
      await _firestoreService.seedMockOrders(user.id);
      _subscribeToOrders(user.id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _ordersSubscription?.cancel();
      _ordersSubscription = null;
      _orders = [];
      _cart = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Cart Actions ──────────────────────────────────────────────────────────

  void addToCart(ProductModel product, String? size, DateTime start, DateTime end) {
    _cart = CartItem(
      product: product,
      selectedSize: size,
      startDate: start,
      endDate: end,
    );
    notifyListeners();
  }

  void removeFromCart() {
    _cart = null;
    notifyListeners();
  }

  // ── Order Actions ─────────────────────────────────────────────────────────

  Future<OrderModel> confirmBooking({
    required String deliveryType,
    String? deliveryAddress,
    required bool isGuaranteeAccepted,
  }) async {
    if (_cart == null) throw Exception('Keranjang kosong');
    if (currentUser == null) throw Exception('Belum login');

    _isLoading = true;
    notifyListeners();

    try {
      final order = OrderModel(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        product: _cart!.product,
        startDate: _cart!.startDate,
        endDate: _cart!.endDate,
        totalPrice: _cart!.totalPrice,
        deliveryType: deliveryType,
        deliveryAddress: deliveryAddress,
        selectedSize: _cart!.selectedSize,
        orderDate: DateTime.now(),
        isGuaranteeAccepted: isGuaranteeAccepted,
      );

      await Future.wait([
        _firestoreService.createOrder(order, currentUser!.id),
        _firestoreService.updateProductAvailability(_cart!.product.id, false),
      ]);

      _cart = null;
      return order;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mengembalikan barang agar tersedia kembali
  Future<void> returnProduct(String productId) async {
    await _firestoreService.updateProductAvailability(productId, true);
  }

  // Aksi Admin: Menambahkan barang sewa baru
  Future<void> addProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.addProduct(product);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aksi Admin: Memperbarui data barang sewa yang ada
  Future<void> updateProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateProduct(product);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aksi Admin: Menghapus barang sewa
  Future<void> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteProduct(productId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
