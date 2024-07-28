import 'package:cloud_firestore/cloud_firestore.dart';

class TourModel {
  final String uId;
  final String tourId;
  final String tourName;
  final String salePrice;
  final String fullPrice;
  final String tourAddress;
  final String tourStreet;
  final String tourCity;
  final List<String> tourImages;
  final String duration;
  final bool isSale;
  final String tourDescription;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  TourModel({
    required this.uId,
    required this.tourId,
    required this.tourName,
    required this.salePrice,
    required this.fullPrice,
    required this.tourAddress,
    required this.tourStreet,
    required this.tourCity,
    required this.tourImages,
    required this.duration,
    required this.isSale,
    required this.tourDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TourModel.fromMap(Map<String, dynamic> data) {
    return TourModel(
      uId: data['uId'] ?? '',
      tourId: data['tourId'] ?? '',
      tourName: data['tourName'] ?? '',
      salePrice: data['salePrice'] ?? '',
      fullPrice: data['fullPrice'] ?? '',
      tourAddress: data['Address'] ?? '',
      tourStreet: data['street'] ?? '',
      tourCity: data['city'] ?? '',
      tourImages: List<String>.from(data['tourImages'] ?? []),
      duration: data['duration'] ?? '',
      isSale: data['isSale'] ?? false,
      tourDescription: data['tourDescription'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  factory TourModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourModel.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'tourId': tourId,
      'tourName': tourName,
      'salePrice': salePrice,
      'fullPrice': fullPrice,
      'Address': tourAddress,
      'street': tourStreet,
      'city': tourCity,
      'tourImages': tourImages,
      'duration': duration,
      'isSale': isSale,
      'tourDescription': tourDescription,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
