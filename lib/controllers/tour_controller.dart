import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flufir/models/tour_model.dart';

class TourController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> addTour(
      String userId,
      String tourName,
      String tourDes,
      String salePrice,
      String fullPrice,
      String Address,
      String street,
      String city,
      String duration,
      File? tourImg,
      ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userRef = _firestore.collection('users').doc(userId);
        final userData = await userRef.get();

        if (!userData.exists || !userData.data()!.containsKey('tours')) {
          await userRef.set({'tours': [], 'isAdmin': false}, SetOptions(merge: true));
        }

        final tourRef = _firestore.collection('tours').doc();
        bool isSale = salePrice.isNotEmpty;

        TourModel newTour = TourModel(
          uId: userId,
          tourId: tourRef.id,
          tourName: tourName,
          tourDescription: tourDes,
          salePrice: salePrice,
          fullPrice: fullPrice,
          tourAddress: Address,
          tourStreet: street,
          tourCity: city,
          tourImages: [],
          duration: duration,
          isSale: isSale, // Set based on salePrice
          createdAt: Timestamp.now(), // Set timestamp at creation
          updatedAt: Timestamp.now(), // Set timestamp at creation
        );

        await tourRef.set(newTour.toMap());

        if (tourImg != null) {
          final String storageUrl = await _uploadImageToStorage(tourRef.id, tourImg);
          await tourRef.update({
            'tourImages': FieldValue.arrayUnion([storageUrl])
          });
        }

        final List<dynamic> userTours = List.from(userData['tours'] ?? []);
        userTours.add(tourRef.id);

        await userRef.update({'tours': userTours});

        if (!userData['isAdmin'] && userTours.isNotEmpty) {
          await userRef.update({'isAdmin': true});
        }

        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("Failed to create tour: $error");
      return false;
    }
  }

  Future<String> _uploadImageToStorage(String tourId, File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child('tours/$tourId/tour_image.jpg');
      final uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
      final imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (error) {
      print("Failed to upload image: $error");
      throw error;
    }
  }

  Future<bool> updateTour(
      String tourId,
      String tourName,
      String tourDes,
      String salePrice,
      String fullPrice,
      String Address,
      String street,
      String city,
      String duration,
      File? tourImg,
      ) async {
    try {
      final tourRef = _firestore.collection('tours').doc(tourId);

      bool isSale = salePrice.isNotEmpty;

      Map<String, dynamic> updatedData = {
        'tourName': tourName,
        'tourDescription': tourDes,
        'salePrice': salePrice,
        'fullPrice': fullPrice,
        'tourAddress': Address,
        'tourStreet': street,
        'tourCity': city,
        'duration': duration,
        'isSale': isSale,
        'updatedAt': Timestamp.now(),
      };

      if (tourImg != null) {
        final String storageUrl = await _uploadImageToStorage(tourId, tourImg);
        updatedData['tourImages'] = FieldValue.arrayUnion([storageUrl]);
      }

      await tourRef.update(updatedData);
      return true;
    } catch (error) {
      print("Failed to update tour: $error");
      return false;
    }
  }

  Future<List<TourModel>> getUserTours(String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userData = await userRef.get();

      if (userData.exists && userData.data()!.containsKey('tours')) {
        final List<dynamic>? userTourIds = userData['tours'];

        if (userTourIds != null) {
          final List<TourModel> userTours = [];
          for (var tourId in userTourIds) {
            if (tourId is String) {
              final tourSnapshot = await _firestore.collection('tours').doc(tourId).get();
              if (tourSnapshot.exists) {
                final data = tourSnapshot.data()!;
                final tour = TourModel(
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
                userTours.add(tour);
              }
            }
          }
          return userTours;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (error) {
      print("Failed to get user tours: $error");
      return [];
    }
  }

  Future<bool> deleteTour(String tourId, String userId) async {
    try {
      final tourRef = _firestore.collection('tours').doc(tourId);
      final tourData = await tourRef.get();

      if (tourData.exists && tourData.data()!['uId'] == userId) {
        final tourImages = List<String>.from(tourData.data()!['tourImages']);
        for (var imageUrl in tourImages) {
          final storageRef = _storage.refFromURL(imageUrl);
          await storageRef.delete();
        }

        await tourRef.delete();

        final userRef = _firestore.collection('users').doc(userId);
        await userRef.update({
          'tours': FieldValue.arrayRemove([tourId])
        });

        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("Failed to delete tour: $error");
      return false;
    }
  }
}
