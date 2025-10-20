// money_receipt_model.dart




import 'package:general_insurance_management_system/model/carbill_model.dart';

class CarMoneyReceiptModel {
  int? id;
  String? issuingOffice;
  String? classOfInsurance;
  DateTime? date;
  String? modeOfPayment;
  String? issuedAgainst;
  CarBillModel? carBill;

  // Constructor
  CarMoneyReceiptModel({
    this.id,
    this.issuingOffice,
    this.classOfInsurance,
    this.date,
    this.modeOfPayment,
    this.issuedAgainst,
    this.carBill,
  });

  // Factory constructor for creating a new MoneyReceiptModel instance from a JSON map
  CarMoneyReceiptModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    issuingOffice = json['issuingOffice'];
    classOfInsurance = json['classOfInsurance'];
    date = json['date'] != null ? DateTime.parse(json['date']) : null; // Parse date
    modeOfPayment = json['modeOfPayment'];
    issuedAgainst = json['issuedAgainst'];
    carBill = json['carBill'] != null ? CarBillModel.fromJson(json['carBill']) : null;
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
    if (carBill != null) {
      data['carBill'] = carBill!.toJson();
    }
    return data;
  }
}