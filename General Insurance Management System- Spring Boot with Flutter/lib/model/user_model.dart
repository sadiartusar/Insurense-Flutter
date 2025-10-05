enum Role {
  ADMIN,
  USER,
}

class UserModel {
  int? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? photo;
  Role? role;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.photo,
    this.role,
  });

  // Factory constructor for creating a UserModel instance from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      photo: json['photo'],
      role: _parseRole(json['role']),
    );
  }

  // Method to convert UserModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'photo': photo,
      'role': role?.toString().split('.').last, // Store role as string
    };
  }
}

// Helper method to parse the role string into the Role enum
Role _parseRole(String? role) {
  if (role == null) return Role.USER; // Default role
  return Role.values.firstWhere(
        (e) => e.toString().split('.').last.toUpperCase() == role.toUpperCase(),
    orElse: () => Role.USER, // Default to USER if no match
  );
}