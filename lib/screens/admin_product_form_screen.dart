import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/app_state.dart';

// ═══════════════════════════════════════════════════════════════
// Form Produk Admin — Reusable untuk Tambah & Edit Barang
// Jika [existingProduct] null  → mode Tambah
// Jika [existingProduct] ada   → mode Edit (field pre-filled)
// ═══════════════════════════════════════════════════════════════
class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? existingProduct;

  const AdminProductFormScreen({super.key, this.existingProduct});

  bool get isEditMode => existingProduct != null;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imageUrlCtrl;
  final TextEditingController _specInputCtrl = TextEditingController();

  late String _selectedCategory;
  late List<String> _selectedSizes;
  late List<String> _specsList;

  final _availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  // Koleksi preset gambar Unsplash per kategori
  final _presetImages = [
    {'label': 'Jas Hitam Set', 'category': 'Pakaian Formal', 'url': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&q=80&w=600'},
    {'label': 'Blazer Slimfit', 'category': 'Pakaian Formal', 'url': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=600'},
    {'label': 'Kebaya Brokat', 'category': 'Pakaian Formal', 'url': 'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?auto=format&fit=crop&q=80&w=600'},
    {'label': 'Laser Pointer', 'category': 'Alat Presentasi/Dokumentasi', 'url': 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?auto=format&fit=crop&q=80&w=600'},
    {'label': 'Tripod Kamera', 'category': 'Alat Presentasi/Dokumentasi', 'url': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=600'},
    {'label': 'Ring Light LED', 'category': 'Alat Presentasi/Dokumentasi', 'url': 'https://images.unsplash.com/photo-1619441207978-3d326c46e2c9?auto=format&fit=crop&q=80&w=600'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;

    // Inisialisasi nilai awal (mode Edit → pre-fill dari data produk yang ada)
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.pricePerDay.toInt().toString() : '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategory = p?.category ?? 'Pakaian Formal';

    // Pre-fill ukuran hanya kode huruf (S, M, L, ...) dari sizeGuide
    _selectedSizes = p?.sizeGuide
            ?.map((s) => s.split(' ').first)
            .where(_availableSizes.contains)
            .toList() ??
        ['S', 'M', 'L', 'XL'];

    _specsList = List<String>.from(p?.specs ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    _specInputCtrl.dispose();
    super.dispose();
  }

  // Tambah spesifikasi ke list
  void _addSpec() {
    final s = _specInputCtrl.text.trim();
    if (s.isNotEmpty) {
      setState(() {
        _specsList.add(s);
        _specInputCtrl.clear();
      });
    }
  }

  // Simpan atau Perbarui barang
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final imageUrl = _imageUrlCtrl.text.trim();
    if (imageUrl.isEmpty) {
      _showSnack('Pilih atau masukkan URL gambar barang.', isError: true);
      return;
    }

    if (_selectedCategory == 'Pakaian Formal' && _selectedSizes.isEmpty) {
      _showSnack('Pilih minimal satu ukuran pakaian.', isError: true);
      return;
    }

    if (_selectedCategory == 'Alat Presentasi/Dokumentasi' && _specsList.isEmpty) {
      _showSnack('Tambahkan minimal satu spesifikasi alat.', isError: true);
      return;
    }

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final id = widget.existingProduct?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}';

    final product = ProductModel(
      id: id,
      name: _nameCtrl.text.trim(),
      category: _selectedCategory,
      imageUrl: imageUrl,
      pricePerDay: price,
      description: _descCtrl.text.trim(),
      isAvailable: widget.existingProduct?.isAvailable ?? true,
      sizeGuide: _selectedCategory == 'Pakaian Formal' ? _selectedSizes : null,
      specs: _selectedCategory == 'Alat Presentasi/Dokumentasi' ? _specsList : null,
    );

    final navigator = Navigator.of(context);
    final scaffoldMsg = ScaffoldMessenger.of(context);

    try {
      if (widget.isEditMode) {
        await AppState.instance.updateProduct(product);
      } else {
        await AppState.instance.addProduct(product);
      }

      scaffoldMsg.showSnackBar(SnackBar(
        content: Text(widget.isEditMode ? 'Barang berhasil diperbarui.' : 'Barang berhasil ditambahkan.'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      navigator.pop();
    } catch (e) {
      _showSnack('Terjadi kesalahan: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF0D47A1);
    final isEdit = widget.isEditMode;

    final filteredPresets = _presetImages.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEdit ? 'Edit Barang' : 'Tambah Barang Baru',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final isLoading = AppState.instance.isLoading;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Seksi: Informasi Umum ──────────────────────────────────
                        _sectionTitle('Informasi Umum'),
                        const SizedBox(height: 14),

                        _fieldLabel('Nama Barang'),
                        const SizedBox(height: 6),
                        _styledField(
                          child: TextFormField(
                            controller: _nameCtrl,
                            enabled: !isLoading,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration('Misal: Blazer Navy Slimfit'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Nama barang wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _fieldLabel('Kategori'),
                        const SizedBox(height: 6),
                        _styledField(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: _inputDecoration(''),
                            items: const [
                              DropdownMenuItem(value: 'Pakaian Formal', child: Text('👔  Pakaian Formal')),
                              DropdownMenuItem(value: 'Alat Presentasi/Dokumentasi', child: Text('🎙️  Alat Presentasi / Dokumentasi')),
                            ],
                            onChanged: isLoading
                                ? null
                                : (v) {
                                    if (v != null) {
                                      setState(() {
                                        _selectedCategory = v;
                                        _imageUrlCtrl.clear();
                                      });
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(height: 16),

                        _fieldLabel('Harga Sewa per Hari (Rp)'),
                        const SizedBox(height: 6),
                        _styledField(
                          child: TextFormField(
                            controller: _priceCtrl,
                            enabled: !isLoading,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration('Misal: 50000'),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                              if (double.tryParse(v) == null) return 'Masukkan angka yang valid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        _fieldLabel('Deskripsi Barang'),
                        const SizedBox(height: 6),
                        _styledField(
                          child: TextFormField(
                            controller: _descCtrl,
                            enabled: !isLoading,
                            maxLines: 4,
                            decoration: _inputDecoration('Jelaskan kondisi barang, isi paket, dan keunggulannya...'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Seksi: Gambar Barang ──────────────────────────────────
                        _sectionTitle('Gambar Barang'),
                        const SizedBox(height: 12),

                        Text('Pilih Foto Preset:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),

                        // Preset Gambar (horizontal scroll)
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredPresets.length,
                            itemBuilder: (context, i) {
                              final preset = filteredPresets[i];
                              final isSelected = _imageUrlCtrl.text == preset['url'];
                              return GestureDetector(
                                onTap: isLoading ? null : () => setState(() => _imageUrlCtrl.text = preset['url']!),
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? themeColor : Colors.grey.shade300,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: themeColor.withValues(alpha: 0.25), blurRadius: 8)]
                                        : null,
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: Image.network(preset['url']!, fit: BoxFit.cover,
                                            errorBuilder: (context, error, stack) =>
                                                const Icon(Icons.broken_image_outlined, size: 28)),
                                      ),
                                      if (isSelected)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: themeColor.withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(9),
                                          ),
                                          child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Pratinjau URL yang dipilih / URL kustom
                        _fieldLabel('Atau masukkan URL Gambar'),
                        const SizedBox(height: 6),
                        _styledField(
                          child: TextFormField(
                            controller: _imageUrlCtrl,
                            enabled: !isLoading,
                            decoration: _inputDecoration('https://images.unsplash.com/...'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),

                        // Preview gambar yang dimasukkan
                        if (_imageUrlCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                _imageUrlCtrl.text,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Text('URL gambar tidak valid', style: TextStyle(color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),

                        // ── Seksi: Spesifik Kategori (Dinamis) ───────────────────
                        if (_selectedCategory == 'Pakaian Formal') ...[
                          _sectionTitle('Pilih Ukuran Tersedia'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableSizes.map((size) {
                              final isSelected = _selectedSizes.contains(size);
                              return FilterChip(
                                label: Text(size),
                                selected: isSelected,
                                selectedColor: themeColor,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF1E1E1E),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: isSelected ? themeColor : Colors.grey.shade300,
                                  ),
                                ),
                                onSelected: isLoading
                                    ? null
                                    : (selected) => setState(() {
                                          if (selected) { _selectedSizes.add(size); }
                                          else { _selectedSizes.remove(size); }
                                        }),
                              );
                            }).toList(),
                          ),
                        ] else ...[
                          _sectionTitle('Spesifikasi Teknis Alat'),
                          const SizedBox(height: 12),
                          // Input tambah spesifikasi
                          Row(
                            children: [
                              Expanded(
                                child: _styledField(
                                  child: TextField(
                                    controller: _specInputCtrl,
                                    enabled: !isLoading,
                                    decoration: _inputDecoration('Misal: Jangkauan 30 meter'),
                                    onSubmitted: (_) => _addSpec(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  onPressed: isLoading ? null : _addSpec,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Daftar spesifikasi
                          if (_specsList.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Belum ada spesifikasi. Ketik lalu tekan + untuk menambah.',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                              ),
                            )
                          else
                            ...List.generate(_specsList.length, (i) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(radius: 3, backgroundColor: themeColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(_specsList[i], style: const TextStyle(fontSize: 13)),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade400, size: 20),
                                      onPressed: isLoading ? null : () => setState(() => _specsList.removeAt(i)),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Bottom Action Bar ──────────────────────────────────────────
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, -6)),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isLoading ? Colors.grey.shade400 : themeColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: isLoading ? null : _handleSubmit,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(
                              isEdit ? 'Simpan Perubahan' : 'Tambahkan Barang',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Helper Widget ──────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
      );

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF444444)),
      );

  Widget _styledField({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: child,
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      );
}
