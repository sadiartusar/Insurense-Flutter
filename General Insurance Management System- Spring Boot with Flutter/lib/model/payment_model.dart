class Payment {
  final int id;
  final double amount;
  final DateTime paymentDate;
  final String paymentMode;
  final User user;

  Payment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    required this.user,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentMode: json['paymentMode'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMode': paymentMode,
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? photo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
    };
  }
}
