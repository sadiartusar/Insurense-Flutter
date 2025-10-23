

import 'package:general_insurance_management_system/model/user_model.dart';

class AccountModel {
  final int id;
  final double amount;
  final String name;
  final DateTime? paymentDate;
  final String? paymentMode;
  final UserModel? user;

  AccountModel({
    required this.id,
    required this.amount,
    required this.name,
    this.paymentDate,
    this.paymentMode,
    this.user,
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
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
