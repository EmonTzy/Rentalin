import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/app_state.dart';
import 'admin_product_form_screen.dart';
import 'admin_order_detail_screen.dart';

// ═══════════════════════════════════════════════════════════════
// Halaman Dashboard Admin Rentalin
// Menampilkan statistik, daftar barang sewa, dan aksi CRUD
// ═══════════════════════════════════════════════════════════════
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _filterCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Navigasi ke form Tambah Barang
  void _navigateToAddProduct() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminProductFormScreen(),
      ),
    );
  }

  // Navigasi ke form Edit Barang
  void _navigateToEditProduct(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminProductFormScreen(existingProduct: product),
      ),
    );
  }

  // Dialog Konfirmasi Hapus Barang
  Future<void> _confirmDelete(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Barang?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Barang "${product.name}" akan dihapus secara permanen dan tidak dapat dikembalikan.',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await AppState.instance.deleteProduct(product.id);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Barang "${product.name}" berhasil dihapus.'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus barang: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined, size: 20), text: 'Barang'),
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 20), text: 'Statistik'),
            Tab(icon: Icon(Icons.receipt_long_outlined, size: 20), text: 'Pesanan'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildProductsTab(),
              _buildStatisticsTab(),
              _buildOrdersTab(),
            ],
          );
        },
      ),
      // FAB Tambah Barang (hanya tampil di Tab Barang)
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _navigateToAddProduct,
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Barang', style: TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Tab 1: Daftar Barang Sewa (CRUD)
  // ─────────────────────────────────────────────────────────────
  Widget _buildProductsTab() {
    final allProducts = AppState.instance.products;

    // Filter lokal berdasarkan pencarian dan kategori
    final filteredProducts = allProducts.where((p) {
      final matchSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _filterCategory == 'Semua' || p.category == _filterCategory;
      return matchSearch && matchCat;
    }).toList();

    return Column(
      children: [
        // ── Search & Filter Bar ──
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Search field
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari nama barang...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              // Category filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Pakaian Formal', 'Alat Presentasi/Dokumentasi']
                      .map((cat) {
                    final isActive = _filterCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isActive,
                        selectedColor: const Color(0xFF0D47A1),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isActive ? Colors.white : Colors.grey.shade700,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isActive ? const Color(0xFF0D47A1) : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (_) => setState(() => _filterCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // ── Jumlah hasil ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text(
                '${filteredProducts.length} barang ditemukan',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        // ── List Produk ──
        Expanded(
          child: filteredProducts.isEmpty
              ? _buildEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Belum Ada Barang',
                  subtitle: 'Ketuk tombol "Tambah Barang" untuk menambah produk baru.',
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16, 4, 16,
                    MediaQuery.of(context).padding.bottom + 100,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductListTile(filteredProducts[index]);
                  },
                ),
        ),
      ],
    );
  }

  // Kartu item produk di daftar admin
  Widget _buildProductListTile(ProductModel product) {
    final isAvailable = product.isAvailable;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(14, 10, 10, 0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.image_outlined, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1E1E)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  product.category,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(product.pricePerDay),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? const Color(0x202E7D32) : const Color(0x20C62828),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAvailable ? 'Tersedia' : 'Disewa',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
              ),
            ),
          ),
          // Tombol aksi Edit & Hapus
          Divider(height: 1, color: Colors.grey.shade100, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0D47A1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _navigateToEditProduct(product),
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.grey.shade200),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _confirmDelete(product),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Tab 2: Statistik
  // ─────────────────────────────────────────────────────────────
  Widget _buildStatisticsTab() {
    final products = AppState.instance.products;
    final orders = AppState.instance.orders;

    final totalProducts = products.length;
    final availableProducts = products.where((p) => p.isAvailable).length;
    final rentedProducts = products.where((p) => !p.isAvailable).length;
    final formalWear = products.where((p) => p.isFormalWear).length;
    final equipment = products.where((p) => p.isEquipment).length;
    final totalRevenue = orders.fold(0.0, (sum, o) => sum + o.totalPrice);
    final totalOrders = orders.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Ringkasan Inventaris',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        ),
        const SizedBox(height: 14),
        // Grid Statistik Produk
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard('Total Barang', '$totalProducts', Icons.inventory_2_outlined, const Color(0xFF0D47A1)),
            _buildStatCard('Tersedia', '$availableProducts', Icons.check_circle_outline, const Color(0xFF2E7D32)),
            _buildStatCard('Sedang Disewa', '$rentedProducts', Icons.access_time_rounded, const Color(0xFFF57C00)),
            _buildStatCard('Pakaian Formal', '$formalWear', Icons.dry_cleaning_outlined, const Color(0xFF7B1FA2)),
            _buildStatCard('Alat Presentasi', '$equipment', Icons.slideshow_rounded, const Color(0xFF0288D1)),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Ringkasan Transaksi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard('Total Pesanan', '$totalOrders', Icons.receipt_long_outlined, const Color(0xFF0D47A1)),
            _buildStatCard('Total Pendapatan', _formatRupiah(totalRevenue), Icons.payments_outlined, const Color(0xFF2E7D32)),
          ],
        ),
        const SizedBox(height: 24),
        // Distribusi Ketersediaan visual (bar)
        if (totalProducts > 0) ...[
          const Text(
            'Distribusi Ketersediaan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _buildProgressBar('Tersedia', availableProducts, totalProducts, const Color(0xFF2E7D32)),
                const SizedBox(height: 12),
                _buildProgressBar('Sedang Disewa', rentedProducts, totalProducts, const Color(0xFFF57C00)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final pct = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$value dari $total', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Tab 3: Daftar Pesanan
  // ─────────────────────────────────────────────────────────────
  Widget _buildOrdersTab() {
    final orders = AppState.instance.orders;

    if (orders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum Ada Pesanan',
        subtitle: 'Pesanan dari mahasiswa akan muncul di sini.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        16, 0, 16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
        final date = '${order.orderDate.day} ${months[order.orderDate.month - 1]} ${order.orderDate.year}';

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminOrderDetailScreen(order: order),
              ),
            );
          },
          child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatRupiah(order.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0D47A1), fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  const SizedBox(width: 12),
                  Icon(
                    order.deliveryType.contains('Diantar') ? Icons.local_shipping_outlined : Icons.storefront_rounded,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryType,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (order.selectedSize != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Ukuran: ${order.selectedSize}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0D47A1), fontWeight: FontWeight.w600),
                ),
              ],
              // Petunjuk tapping
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat Detail',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  // Helper Empty State
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4)),
          ],
        ),
      ),
    );
  }

  // Helper Format Rupiah
  String _formatRupiah(double value) {
    final intVal = value.toInt();
    final str = intVal.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buf.write(str[i]);
      count++;
      if (count == 3 && i != 0) { buf.write('.'); count = 0; }
    }
    return 'Rp ${buf.toString().split('').reversed.join('')}';
  }
}
