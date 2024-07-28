import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/controllers/get_device_controller.dart';
import 'package:flufir/models/user_model.dart';
import 'package:flufir/screens/user/main.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInController extends GetxController {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String defaultAvatarUrl = 'https://firebasestorage.googleapis.com/v0/b/travelapp-98c84.appspot.com/o/proto%2Fdefault_avatar.jpg?alt=media&token=1cbe64bc-a338-48ce-a9d1-b6a9eb1ac3f2';

  Future<void> signInWithGoogle() async {
    final GetDeviceTokenController getDeviceTokenController =
    Get.put(GetDeviceTokenController());
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        EasyLoading.show(status: "Please wait..");
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        final User? user = userCredential.user;

        if (user != null) {
          // Kiểm tra xem user.photoURL có null hay không
          String userPhotoUrl = user.photoURL ?? defaultAvatarUrl;

          UserModel userModel = UserModel(
            uId: user.uid,
            username: user.displayName ?? "No name",
            email: user.email ?? "No email",
            phone: user.phoneNumber ?? "No phone number",
            userImg: userPhotoUrl,
            userAddress: '',
            street: '',
            isAdmin: false,
            createdOn: DateTime.now(),
            city: '',
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
          EasyLoading.dismiss();
          Get.offAll(() => MainScreen());
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      print("error $e");
    }
  }
}
