import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>(<String, dynamic>{});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUserData(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await _firestore.collection('users').doc(userId).get();

      if (documentSnapshot.exists) {
        userData.value = documentSnapshot.data()!;
      } else {
        Get.snackbar('Error', 'User data not found');
      }
    } catch (error) {
      Get.snackbar('Error', 'Failed to fetch user data: $error');
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>> getUserData(String uId) async {
    try {
      final QuerySnapshot userDataSnapshot =
      await _firestore.collection('users').where('uId', isEqualTo: uId).get();
      return userDataSnapshot.docs;
    } catch (error) {
      Get.snackbar('Error', 'Failed to fetch user data by uId: $error');
      return [];
    }
  }

  Future<bool> updateUserProfile(
      String userId,
      String username,
      String email,
      String phone,
      String address,
      String street,
      String city,
      File? imageFile) async {
    try {
      final Map<String, dynamic> updatedData = {
        'username': username,
        'email': email,
        'phone': phone,
        'userAddress': address,
        'street': street,
        'city': city,
      };

      if (imageFile != null) {
        final imageUrl = await _uploadImageToStorage(userId, imageFile);
        updatedData['userImg'] = imageUrl;
      }

      await _firestore.collection('users').doc(userId).update(updatedData);
      Get.snackbar('Success', 'Profile updated successfully');
      await fetchUserData(userId);
      return true;
    } catch (error) {
      Get.snackbar('Error', 'Failed to update profile: $error');
      return false;
    }
  }

  Future<String> _uploadImageToStorage(String userId, File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child('users/$userId/profile_image.jpg');
      final uploadTask = storageReference.putFile(imageFile);
      await uploadTask;
      final imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (error) {
      throw error;
    }
  }
}
