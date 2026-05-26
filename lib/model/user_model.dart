class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'organizador' | 'user'

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isOrganizador => role == 'organizador';

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
    );
  }
}
