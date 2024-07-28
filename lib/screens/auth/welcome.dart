import 'package:flufir/controllers/google_sign_in_controller.dart';
import 'package:flufir/screens/auth/sign_in.dart';
import 'package:flufir/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final GoogleSignInController _googleSignInController =
  Get.put(GoogleSignInController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppConstant.appScendoryColor,
        title: const Text("Welcome to my app"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Lottie.asset('assets/images/splash2.json'),
          ),
          Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: const Text(
                "Happy Shopping",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: Get.height / 12,
          ),
          Material(
            child: Container(
              width: Get.width / 1.3,
              height: Get.height / 12,
              decoration: BoxDecoration(
                  color: AppConstant.appScendoryColor,
                  borderRadius: BorderRadius.circular(20.0)),
              child: TextButton.icon(
                icon: Image.asset(
                  'assets/images/google.png',
                  width: Get.width / 12,
                  height: Get.height / 12,
                ),
                label: const Text(
                  "Sign in with google",
                  style: TextStyle(color: AppConstant.appTextColor),
                ),
                onPressed: () {
                  _googleSignInController.signInWithGoogle();
                },
              ),
            ),
          ),
          SizedBox(
            height: Get.height / 45,
          ),
          Material(
            child: Container(
              width: Get.width / 1.3,
              height: Get.height / 12,
              decoration: BoxDecoration(
                  color: AppConstant.appScendoryColor,
                  borderRadius: BorderRadius.circular(20.0)),
              child: TextButton.icon(
                icon: Image.asset(
                  'assets/images/gmail.png',
                  width: Get.width / 12,
                  height: Get.height / 12,
                ),
                label: const Text(
                  "Sign in with email",
                  style: TextStyle(color: AppConstant.appTextColor),
                ),
                onPressed: () {
                  Get.off(()=> const SignInScreen());
                },

              ),

            ),
          ),
        ],
      ),
    );
  }
}