import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import 'mock_auth_service.dart';
import 'mock_product_service.dart';

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

// Global State Provider menggunakan ChangeNotifier bawaan Flutter
class AppState extends ChangeNotifier {
  // Singleton pattern agar state dapat diakses secara global
  static final AppState instance = AppState._internal();
  AppState._internal() {
    // Muat data katalog awal
    _products = _productService.getProducts();
  }

  final MockAuthService _authService = MockAuthService();
  final MockProductService _productService = MockProductService();

  List<ProductModel> _products = [];
  CartItem? _cart; // Rentalin menggunakan single-item checkout untuk pemesanan super cepat sidang
  final List<OrderModel> _orders = [];
  bool _isLoading = false;

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
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' || product.category == _selectedCategory;
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

  // Authentication Actions
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
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
      _cart = null; // Bersihkan keranjang saat logout
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cart Actions
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

  // Order Actions (Checkout & Booking Confirmation)
  Future<OrderModel> confirmBooking({
    required String deliveryType,
    String? deliveryAddress,
    required bool isGuaranteeAccepted,
  }) async {
    if (_cart == null) {
      throw Exception('Keranjang kosong');
    }

    _isLoading = true;
    notifyListeners();

    // Simulasi pemrosesan checkout di Firestore
    await Future.delayed(const Duration(milliseconds: 1000));

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

    // Tambahkan ke riwayat pesanan
    _orders.insert(0, order);

    // Ubah ketersediaan barang secara real-time di Firestore simulasi
    _productService.updateAvailability(_cart!.product.id, false);
    
    // Refresh daftar produk lokal
    _products = _productService.getProducts();

    // Kosongkan keranjang
    _cart = null;

    _isLoading = false;
    notifyListeners();

    return order;
  }

  // Mengembalikan barang agar tersedia kembali (opsional untuk simulasi demo)
  void returnProduct(String productId) {
    _productService.updateAvailability(productId, true);
    _products = _productService.getProducts();
    notifyListeners();
  }
}
