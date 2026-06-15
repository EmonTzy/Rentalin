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

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      nrp: data['nrp'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'nrp': nrp,
    };
  }

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
