import '../models/product.dart';

// Layanan simulasi Firestore Database untuk Katalog Produk
class MockProductService {
  final List<ProductModel> _products = [
    ProductModel(
      id: 'prod_jas_premium',
      name: 'Jas Set Lengkap (Premium)',
      category: 'Pakaian Formal',
      imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&q=80&w=600',
      pricePerDay: 50000.0,
      description: 'Setelan jas premium hitam formal lengkap untuk kebutuhan sidang skripsi, yudisium, atau wawancara kerja. Paket sewa sudah termasuk: Jas luar, celana bahan hitam, kemeja putih lengan panjang, dasi hitam, dan hanger pelindung.',
      isAvailable: true,
      sizeGuide: ['S (Lebar Dada 48cm)', 'M (Lebar Dada 50cm)', 'L (Lebar Dada 52cm)', 'XL (Lebar Dada 54cm)', 'XXL (Lebar Dada 56cm)'],
    ),
    ProductModel(
      id: 'prod_kebaya_modern',
      name: 'Kebaya Modern Brokat',
      category: 'Pakaian Formal',
      imageUrl: 'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?auto=format&fit=crop&q=80&w=600',
      pricePerDay: 65000.0,
      description: 'Kebaya modern dengan detail brokat halus dan bawahan rok batik Surabaya yang elegan. Sangat cocok untuk mahasiswi yang akan melaksanakan wisuda, yudisium, atau acara formal kampus lainnya. Nyaman digunakan seharian.',
      isAvailable: true,
      sizeGuide: ['S (Lingkar Dada 88cm)', 'M (Lingkar Dada 92cm)', 'L (Lingkar Dada 96cm)', 'XL (Lingkar Dada 100cm)'],
    ),
    ProductModel(
      id: 'prod_blazer_casual',
      name: 'Blazer Hitam Slimfit',
      category: 'Pakaian Formal',
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?auto=format&fit=crop&q=80&w=600',
      pricePerDay: 35000.0,
      description: 'Blazer hitam dengan potongan slimfit semi-formal yang fleksibel. Cocok bagi mahasiswa yang ingin tampil rapi namun tetap kasual saat presentasi proyek kuliah atau seminar hasil.',
      isAvailable: true,
      sizeGuide: ['S', 'M', 'L', 'XL'],
    ),
    ProductModel(
      id: 'prod_pointer_logi',
      name: 'Laser Pointer Logitech Spotlight',
      category: 'Alat Presentasi/Dokumentasi',
      imageUrl: 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?auto=format&fit=crop&q=80&w=600',
      pricePerDay: 15000.0,
      description: 'Pointer presentasi profesional tercanggih dari Logitech. Membantu Anda menyoroti (highlight) dan memperbesar (magnify) area presentasi di layar proyektor dengan sangat jelas. Sidang skripsi dijamin lebih meyakinkan!',
      isAvailable: true,
      specs: [
        'Konektivitas: Bluetooth Smart dan 2.4GHz Wireless Connection',
        'Jangkauan Operasional: Hingga 30 meter',
        'Fitur Utama: Highlight, Magnify, Kontrol Volume, dan Timer Pengingat',
        'Daya: Baterai isi ulang cepat (charger USB tipe C)'
      ],
    ),
    ProductModel(
      id: 'prod_tripod_hp',
      name: 'Tripod HP & Kamera Takara 1.5m',
      category: 'Alat Presentasi/Dokumentasi',
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=600',
      pricePerDay: 10000.0,
      description: 'Tripod ringan dengan dudukan HP (phone holder) dan sekrup universal untuk kamera mirrorless. Sangat berguna untuk dokumentasi sidang, perekaman video ujian mengajar, atau pembuatan konten presentasi tugas akhir.',
      isAvailable: true,
      specs: [
        'Tinggi Maksimum: 150 cm',
        'Tinggi Minimum: 45 cm (sangat ringkas dibawa)',
        'Bahan: Aluminium Alloy ringan kokoh',
        'Kapasitas Beban Maksimal: 2 kg',
        'Sudah termasuk tas tripod dan U-holder HP premium'
      ],
    ),
    ProductModel(
      id: 'prod_ring_light',
      name: 'Ring Light LED + Stand 2 Meter',
      category: 'Alat Presentasi/Dokumentasi',
      imageUrl: 'https://images.unsplash.com/photo-1619441207978-3d326c46e2c9?auto=format&fit=crop&q=80&w=600',
      pricePerDay: 20000.0,
      description: 'Lampu penerangan berbentuk ring LED lengkap dengan stand setinggi 2 meter untuk hasil pencahayaan video yang profesional. Sangat disarankan untuk video conference sidang online di kos agar wajah terlihat terang dan jelas.',
      isAvailable: true,
      specs: [
        'Diameter Ring: 26 cm / 10 inci',
        'Mode Cahaya: 3 Warna (Putih Dingin, Kuning Hangat, Kuning Alami)',
        'Tingkat Kecerahan: 10 level intensitas cahaya',
        'Tinggi Stand: Adjustable dari 70cm hingga 200cm',
        'Sumber Daya: Kabel USB (bisa dicolok ke charger HP atau powerbank)'
      ],
    ),
  ];

  // Mendapatkan seluruh produk katalog
  List<ProductModel> getProducts() {
    return _products;
  }

  // Mendapatkan produk berdasarkan ID
  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  // Simulasi perubahan ketersediaan barang secara real-time
  void updateAvailability(String id, bool isAvailable) {
    final index = _products.indexWhere((element) => element.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(isAvailable: isAvailable);
    }
  }
}
