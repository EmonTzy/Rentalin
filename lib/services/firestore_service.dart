import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Products ──────────────────────────────────────────────────────────────

  Stream<List<ProductModel>> productsStream() {
    return _db.collection('products').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateProductAvailability(String id, bool isAvailable) {
    return _db.collection('products').doc(id).update({'isAvailable': isAvailable});
  }

  // Seeds the products collection on first run (does nothing if already populated)
  Future<void> seedProductsIfEmpty(List<ProductModel> defaults) async {
    final snapshot = await _db.collection('products').limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final product in defaults) {
      batch.set(_db.collection('products').doc(product.id), product.toFirestore());
    }
    await batch.commit();
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Stream<List<OrderModel>> ordersStream(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> createOrder(OrderModel order, String userId) {
    return _db.collection('orders').doc(order.id).set(order.toFirestore(userId));
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) {
    return _db
        .collection('users')
        .doc(user.id)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  // ── Mock Data Seeding ─────────────────────────────────────────────────────

  // Creates sample historical orders for [userId]. Safe to call multiple times —
  // skips seeding if the user already has orders in Firestore.
  Future<void> seedMockOrders(String userId) async {
    final existing = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();

    final mockOrders = [
      // Completed rental – jas, picked up, 3 days ago
      OrderModel(
        id: 'mock_ord_001_$userId',
        product: ProductModel(
          id: 'prod_jas_premium',
          name: 'Jas Set Lengkap (Premium)',
          category: 'Pakaian Formal',
          imageUrl:
              'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&q=80&w=600',
          pricePerDay: 50000.0,
          description: 'Setelan jas premium hitam formal lengkap.',
          isAvailable: true,
          sizeGuide: ['S', 'M', 'L', 'XL', 'XXL'],
        ),
        startDate: now.subtract(const Duration(days: 5)),
        endDate: now.subtract(const Duration(days: 4)),
        totalPrice: 50000.0,
        deliveryType: 'Ambil Sendiri di Titik Surabaya',
        deliveryAddress: 'Gedung Rektorat ITS, Lobby Lantai 1',
        selectedSize: 'M (Lebar Dada 50cm)',
        orderDate: now.subtract(const Duration(days: 6)),
        isGuaranteeAccepted: true,
      ),
      // Completed rental – ring light, delivered, 10 days ago
      OrderModel(
        id: 'mock_ord_002_$userId',
        product: ProductModel(
          id: 'prod_ring_light',
          name: 'Ring Light LED + Stand 2 Meter',
          category: 'Alat Presentasi/Dokumentasi',
          imageUrl:
              'https://images.unsplash.com/photo-1619441207978-3d326c46e2c9?auto=format&fit=crop&q=80&w=600',
          pricePerDay: 20000.0,
          description: 'Lampu ring LED dengan stand 2 meter.',
          isAvailable: true,
          specs: ['Diameter Ring: 26 cm', 'Mode Cahaya: 3 Warna'],
        ),
        startDate: now.subtract(const Duration(days: 12)),
        endDate: now.subtract(const Duration(days: 10)),
        totalPrice: 40000.0,
        deliveryType: 'Diantar ke Kos/Kampus',
        deliveryAddress: 'Jl. Keputih Tegal No. 12, Sukolilo, Surabaya',
        orderDate: now.subtract(const Duration(days: 13)),
        isGuaranteeAccepted: true,
      ),
      // Completed rental – laser pointer, picked up, 20 days ago
      OrderModel(
        id: 'mock_ord_003_$userId',
        product: ProductModel(
          id: 'prod_pointer_logi',
          name: 'Laser Pointer Logitech Spotlight',
          category: 'Alat Presentasi/Dokumentasi',
          imageUrl:
              'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?auto=format&fit=crop&q=80&w=600',
          pricePerDay: 15000.0,
          description: 'Pointer presentasi profesional dari Logitech.',
          isAvailable: true,
          specs: ['Jangkauan: 30 meter', 'Konektivitas: Bluetooth & 2.4GHz'],
        ),
        startDate: now.subtract(const Duration(days: 21)),
        endDate: now.subtract(const Duration(days: 20)),
        totalPrice: 15000.0,
        deliveryType: 'Ambil Sendiri di Titik Surabaya',
        deliveryAddress: 'Parkir FILKOM ITS',
        orderDate: now.subtract(const Duration(days: 22)),
        isGuaranteeAccepted: true,
      ),
    ];

    final batch = _db.batch();
    for (final order in mockOrders) {
      batch.set(
        _db.collection('orders').doc(order.id),
        order.toFirestore(userId),
      );
    }
    await batch.commit();
  }
}
