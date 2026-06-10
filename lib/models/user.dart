// Model data untuk menyimpan informasi profil mahasiswa
class UserModel {
  final String id;
  final String email;
  final String name;
  final String nrp; // Nomor Induk Mahasiswa / Nomor Registrasi Pokok

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.nrp,
  });

  // Salin objek dengan beberapa field baru jika diperlukan
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? nrp,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      nrp: nrp ?? this.nrp,
    );
  }
}
