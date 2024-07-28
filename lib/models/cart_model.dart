import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String tourId;
  final String tourName;
  final String salePrice;
  final String fullPrice;
  final List<String> tourImages;
  final String duration;
  final bool isSale;
  final String tourDescription;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  int tourQuantity;
  final double tourTotalPrice;
  final String tourAddress;
  final String tourStreet;
  final String tourCity;

  CartModel({
    required this.tourId,
    required this.tourName,
    required this.salePrice,
    required this.fullPrice,
    required this.tourImages,
    required this.duration,
    required this.isSale,
    required this.tourDescription,
    required this.createdAt,
    required this.updatedAt,
    required this.tourQuantity,
    required this.tourTotalPrice,
    required this.tourAddress,
    required this.tourStreet,
    required this.tourCity,
  });

  factory CartModel.fromMap(Map<String, dynamic> data) {
    return CartModel(
      tourId: data['tourId'] ?? '',
      tourName: data['tourName'] ?? '',
      salePrice: data['salePrice'] ?? '',
      fullPrice: data['fullPrice'] ?? '',
      tourImages: List<String>.from(data['tourImages'] ?? []),
      duration: data['duration'] ?? '',
      isSale: data['isSale'] ?? false,
      tourDescription: data['tourDescription'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      tourQuantity: data['tourQuantity'] ?? 0,
      tourTotalPrice: data['tourTotalPrice'] ?? 0,
      tourAddress: data['tourAddress'] ?? '',
      tourStreet: data['tourStreet'] ?? '',
      tourCity: data['tourCity'] ?? '',
    );
  }

  factory CartModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartModel.fromMap(data);
  }
  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'tourName': tourName,
      'tourDescription': tourDescription,
      'tourAddress': tourAddress,
      'tourStreet': tourStreet,
      'tourCity': tourCity,
      'fullPrice': fullPrice,
      'salePrice': salePrice,
      'isSale': isSale,
      'tourImages': tourImages,
      'duration': duration,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tourQuantity': tourQuantity,
      'tourTotalPrice': tourTotalPrice,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'tourId': tourId,
      'tourName': tourName,
      'salePrice': salePrice,
      'fullPrice': fullPrice,
      'tourImages': tourImages,
      'duration': duration,
      'isSale': isSale,
      'tourDescription': tourDescription,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'tourQuantity': tourQuantity,
      'tourTotalPrice': tourTotalPrice,
      'tourAddress': tourAddress,
      'tourStreet': tourStreet,
      'tourCity': tourCity,
    };
  }
}
