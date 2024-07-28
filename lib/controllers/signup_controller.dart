import 'package:flufir/utils/constant.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flufir/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String defaultAvatarUrl = 'https://firebasestorage.googleapis.com/v0/b/travelapp-98c84.appspot.com/o/proto%2Fdefault_avatar.jpg?alt=media&token=1cbe64bc-a338-48ce-a9d1-b6a9eb1ac3f2';

  var isPasswordVisible = false.obs;

  Future<UserCredential?> signUpMethod(
      String userName,
      String userEmail,
      String userPhone,
      String userAddress,
      String userStreet,
      String userCity,
      String userPassword,
      ) async {
    try {
      EasyLoading.show(status: "Please wait");
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      );

      await userCredential.user!.sendEmailVerification();

      UserModel userModel = UserModel(
        uId: userCredential.user!.uid,
        username: userName,
        email: userEmail,
        phone: userPhone,
        userImg: defaultAvatarUrl,  // Sử dụng ảnh đại diện mặc định
        userAddress: userAddress,
        street: userStreet,
        isAdmin: false,
        createdOn: DateTime.now(),
        city: userCity,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());
      EasyLoading.dismiss();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        "Error",
        "$e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppConstant.appScendoryColor,
        colorText: AppConstant.appTextColor,
      );
    }
  }
}
