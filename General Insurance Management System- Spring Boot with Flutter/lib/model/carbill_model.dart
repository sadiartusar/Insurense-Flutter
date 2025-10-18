import 'dart:convert';

import 'package:general_insurance_management_system/model/carpolicy_model.dart';
import 'package:general_insurance_management_system/model/firepolicy_model.dart';


class CarBillModel {
  int? id;
  double? carRate;
  double? rsd;
  double? netPremium;
  double? tax;
  double? grossPremium;
  CarPolicyModel carPolicy;


  CarBillModel({
    this.id, // Nullable ID
    required this.carRate,
    required this.rsd,
    required this.netPremium,
    required this.tax,
    required this.grossPremium,
    required this.carPolicy
  });

  /// Factory constructor to create a MarineBillModel from a JSON map
  factory CarBillModel.fromJson(Map<String, dynamic> json) {
    return CarBillModel(
      id: json['id'], // Nullable ID
      carRate: (json['carRate'] is num) ? json['carRate'].toDouble() : 0.0,
      rsd: (json['rsd'] is num) ? json['rsd'].toDouble() : 0.0,
      netPremium: (json['netPremium'] is num) ? json['netPremium'].toDouble() : 0.0,
      tax: (json['tax'] is num) ? json['tax'].toDouble() : 0.0,
      grossPremium: (json['grossPremium'] is num) ? json['grossPremium'].toDouble() : 0.0,
      carPolicy: CarPolicyModel.fromJson(json['carPolicy']),
    );
  }



  /// Convert the MarineBillModel object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carRate': carRate,
      'rsd': rsd,
      'netPremium': netPremium,
      'tax': tax,
      'grossPremium': grossPremium,
      'carPolicy': carPolicy.toJson(),
    };
  }
}