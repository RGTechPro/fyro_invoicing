import 'package:hive/hive.dart';

class Challan extends HiveObject {
  final String id;
  final String challanNumber;
  final DateTime date;
  final String fromCompany;
  final String toCompany;
  final String deliveryAddress;
  final List<ChallanItem> items;
  final String? remarks;
  final DateTime createdAt;

  Challan({
    required this.id,
    required this.challanNumber,
    required this.date,
    required this.fromCompany,
    required this.toCompany,
    required this.deliveryAddress,
    required this.items,
    this.remarks,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'challanNumber': challanNumber,
        'date': date.toIso8601String(),
        'fromCompany': fromCompany,
        'toCompany': toCompany,
        'deliveryAddress': deliveryAddress,
        'items': items.map((item) => item.toJson()).toList(),
        'remarks': remarks,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Challan.fromJson(Map<String, dynamic> json) => Challan(
        id: json['id'],
        challanNumber: json['challanNumber'],
        date: DateTime.parse(json['date']),
        fromCompany: json['fromCompany'],
        toCompany: json['toCompany'],
        deliveryAddress: json['deliveryAddress'],
        items: (json['items'] as List)
            .map((item) => ChallanItem.fromJson(item))
            .toList(),
        remarks: json['remarks'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class ChallanItem extends HiveObject {
  final String description;
  final int quantity;
  final String unit;

  ChallanItem({
    required this.description,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unit': unit,
      };

  factory ChallanItem.fromJson(Map<String, dynamic> json) => ChallanItem(
        description: json['description'],
        quantity: json['quantity'],
        unit: json['unit'],
      );
}
