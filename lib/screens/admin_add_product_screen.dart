import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/app_state.dart';
import '../widgets/custom_button.dart';

// Halaman Admin: Menambah Barang Rental Baru ke Firebase
class AdminAddProductScreen extends StatefulWidget {
  const AdminAddProductScreen({super.key});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _specInputController = TextEditingController();

  String _selectedCategory = 'Pakaian Formal';
  
  // State untuk Pakaian Formal (Daftar ukuran yang dipilih)
  final List<String> _availableSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _selectedSizes = ['S', 'M', 'L', 'XL']; // default

  // State untuk Alat Presentasi (Daftar spesifikasi teknis)
  final List<String> _specsList = [];

  // Gambar Preset Unsplash untuk kemudahan demo pengisian
  final List<Map<String, String>> _presetImages = [
    {
      'name': 'Jas Set Premium',
      'category': 'Pakaian Formal',
      'url': 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&q=80&w=600'
    },
    {
      'name': 'Blazer Hitam Slimfit',
      'category': 'Pakaian Formal',
      'url': 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=600'
    },
    {
      'name': 'Kebaya Modern Brokat',
      'category': 'Pakaian Formal',
      'url': 'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?auto=format&fit=crop&q=80&w=600'
    },
    {
      'name': 'Logitech Spotlight',
      'category': 'Alat Presentasi/Dokumentasi',
      'url': 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?auto=format&fit=crop&q=80&w=600'
    },
    {
      'name': 'Tripod Hp/Kamera',
      'category': 'Alat Presentasi/Dokumentasi',
      'url': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=600'
    },
    {
      'name': 'Ring Light LED Studio',
      'category': 'Alat Presentasi/Dokumentasi',
      'url': 'https://images.unsplash.com/photo-1619441207978-3d326c46e2c9?auto=format&fit=crop&q=80&w=600'
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageUrlController.dispose();
    _specInputController.dispose();
    super.dispose();
  }

  // Fungsi menambah spesifikasi teknis dinamis ke list
  void _addSpecification() {
    final spec = _specInputController.text.trim();
    if (spec.isNotEmpty) {
      setState(() {
        _specsList.add(spec);
        _specInputController.clear();
      });
    }
  }

  // Fungsi menghapus spesifikasi dari list
  void _removeSpecification(int index) {
    setState(() {
      _specsList.removeAt(index);
    });
  }

  // Aksi mengunggah produk baru ke Firebase
  Future<void> _handleSaveProduct(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final description = _descController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih atau masukkan URL gambar produk')),
      );
      return;
    }

    if (_selectedCategory == 'Pakaian Formal' && _selectedSizes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu ukuran pakaian')),
      );
      return;
    }

    if (_selectedCategory == 'Alat Presentasi/Dokumentasi' && _specsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu spesifikasi alat')),
      );
      return;
    }

    final id = 'prod_${DateTime.now().millisecondsSinceEpoch}';

    final newProduct = ProductModel(
      id: id,
      name: name,
      category: _selectedCategory,
      imageUrl: imageUrl,
      pricePerDay: price,
      description: description,
      isAvailable: true,
      sizeGuide: _selectedCategory == 'Pakaian Formal' ? _selectedSizes : null,
      specs: _selectedCategory == 'Alat Presentasi/Dokumentasi' ? _specsList : null,
    );

    final appState = AppState.instance;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await appState.addProduct(newProduct);
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Barang "$name" berhasil diunggah ke Firebase!'),
          backgroundColor: const Color(0xFF2E7D32),
        ),
      );
      navigator.pop();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan barang: ${e.toString()}'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFD0D47A1);
    final filteredPresets = _presetImages.where((preset) => preset['category'] == _selectedCategory).toList();
    final appState = AppState.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E1E1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Admin Panel: Tambah Barang',
          style: TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          final isLoading = appState.isLoading;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Informasi Umum ──
                          const Text(
                            'Informasi Umum',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nama Produk
                          const Text('Nama Barang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            enabled: !isLoading,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Misal: Blazer Navy Slimfit',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama barang tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Kategori
                          const Text('Kategori Rental', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(),
                            items: const [
                              DropdownMenuItem(value: 'Pakaian Formal', child: Text('Pakaian Formal (Jas, Kebaya)')),
                              DropdownMenuItem(
                                value: 'Alat Presentasi/Dokumentasi',
                                child: Text('Alat Presentasi/Dokumentasi (Pointer, Tripod)'),
                              ),
                            ],
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedCategory = value;
                                        _imageUrlController.clear();
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: 20),

                          // Harga per Hari
                          const Text('Harga Sewa Per Hari (Rp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priceController,
                            enabled: !isLoading,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Misal: 40000',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Harga sewa tidak boleh kosong';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Masukkan angka harga sewa yang valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Deskripsi
                          const Text('Deskripsi Lengkap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descController,
                            enabled: !isLoading,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Jelaskan kondisi barang, isi paket sewa, atau keunggulan lainnya...',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Deskripsi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // ── Media & Gambar ──
                          const Text(
                            'Gambar Barang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Pilihan Preset Gambar Cepat
                          Text(
                            'Pilih Preset Gambar Cepat (Sesuai Kategori):',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 75,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredPresets.length,
                              itemBuilder: (context, index) {
                                final preset = filteredPresets[index];
                                final isSelected = _imageUrlController.text == preset['url'];

                                return GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _imageUrlController.text = preset['url']!;
                                          });
                                        },
                                  child: Container(
                                    width: 75,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? themeColor : Colors.grey.shade200,
                                        width: isSelected ? 3 : 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: Image.network(
                                        preset['url']!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, size: 24),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // URL Gambar Manual
                          const Text('Atau URL Gambar Kustom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _imageUrlController,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              hintText: 'https://images.unsplash.com/...',
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Spesifik Kategori (Dinamis) ──
                          if (_selectedCategory == 'Pakaian Formal') ...[
                            const Text(
                              'Panduan Ukuran Pakaian',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Pilihan Chips Ukuran
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
                                      : (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedSizes.add(size);
                                            } else {
                                              _selectedSizes.remove(size);
                                            }
                                          });
                                        },
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            const Text(
                              'Spesifikasi Teknis Alat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Input Spesifikasi Tambahan
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _specInputController,
                                    enabled: !isLoading,
                                    decoration: const InputDecoration(
                                      hintText: 'Misal: Jangkauan Laser 30 meter',
                                    ),
                                    onSubmitted: (_) => _addSpecification(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: themeColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    onPressed: isLoading ? null : _addSpecification,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Daftar Spesifikasi yang sudah ditambah
                            if (_specsList.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Belum ada spesifikasi ditambahkan. Tekan tombol + untuk menambah.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _specsList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 3,
                                          backgroundColor: themeColor,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _specsList[index],
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E)),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                          onPressed: isLoading ? null : () => _removeSpecification(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Bottom Submit Bar
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
                  child: CustomButton(
                    text: 'Simpan & Upload ke Firebase',
                    isLoading: isLoading,
                    onPressed: () => _handleSaveProduct(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
