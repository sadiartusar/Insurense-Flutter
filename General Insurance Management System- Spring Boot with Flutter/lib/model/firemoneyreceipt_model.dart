// money_receipt_model.dart


import 'package:general_insurance_management_system/model/firebill_model.dart';

class FireMoneyReceiptModel {
  int? id;
  String? issuingOffice;
  String? classOfInsurance;
  DateTime? date;
  String? modeOfPayment;
  String? issuedAgainst;
  FirebillModel? fireBill;

  // Constructor
  FireMoneyReceiptModel({
    this.id,
    this.issuingOffice,
    this.classOfInsurance,
    this.date,
    this.modeOfPayment,
    this.issuedAgainst,
    this.fireBill,
  });

  // Factory constructor for creating a new MoneyReceiptModel instance from a JSON map
  FireMoneyReceiptModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    issuingOffice = json['issuingOffice'];
    classOfInsurance = json['classOfInsurance'];
    date = json['date'] != null ? DateTime.parse(json['date']) : null; // Parse date
    modeOfPayment = json['modeOfPayment'];
    issuedAgainst = json['issuedAgainst'];
    fireBill = json['fireBill'] != null ? FirebillModel.fromJson(json['fireBill']) : null;
  }

  // Method to convert an instance of MoneyReceiptModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['issuingOffice'] = issuingOffice;
    data['classOfInsurance'] = classOfInsurance;
    data['date'] = date?.toIso8601String(); // Convert DateTime to ISO 8601 string
    data['modeOfPayment'] = modeOfPayment;
    data['issuedAgainst'] = issuedAgainst;
    if (fireBill != null) {
      data['fireBill'] = fireBill!.toJson();
    }
    return data;
  }
}