import 'dart:convert';

import 'package:general_insurance_management_system/model/firepolicy_model.dart';


class FirebillModel {
  int? id;
  double? fire;
  double? rsd;
  double? netPremium;
  double? tax;
  double? grossPremium;
  PolicyModel firePolicy;


  FirebillModel({
    this.id, // Nullable ID
    required this.fire,
    required this.rsd,
    required this.netPremium,
    required this.tax,
    required this.grossPremium,
    required this.firePolicy
  });

  /// Factory constructor to create a MarineBillModel from a JSON map
  factory FirebillModel.fromJson(Map<String, dynamic> json) {
    return FirebillModel(
      id: json['id'], // Nullable ID
      fire: (json['fire'] is num) ? json['fire'].toDouble() : 0.0,
      rsd: (json['rsd'] is num) ? json['rsd'].toDouble() : 0.0,
      netPremium: (json['netPremium'] is num) ? json['netPremium'].toDouble() : 0.0,
      tax: (json['tax'] is num) ? json['tax'].toDouble() : 0.0,
      grossPremium: (json['grossPremium'] is num) ? json['grossPremium'].toDouble() : 0.0,
      firePolicy: PolicyModel.fromJson(json['firePolicy']),
    );
  }



  /// Convert the MarineBillModel object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fire': fire,
      'rsd': rsd,
      'netPremium': netPremium,
      'tax': tax,
      'grossPremium': grossPremium,
      'firePolicy': firePolicy.toJson(),
    };
  }
}