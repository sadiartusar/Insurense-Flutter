import 'package:general_insurance_management_system/model/payment_model.dart';

class AccountModel {
  final int id;
  final double amount;
  final String name;
  final DateTime? paymentDate;
  final String? paymentMode;
  final User? user;

  AccountModel({
    required this.id,
    required this.amount,
    required this.name,
    this.paymentDate,
    this.paymentMode,
    this.user
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      name: json['name'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      paymentMode: json['paymentMode'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
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
