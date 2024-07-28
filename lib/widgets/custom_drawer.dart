import 'package:flufir/screens/user/list_message.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../controllers/user_profile_controller.dart';
import '../screens/auth/welcome.dart';
import '../screens/user/all_tours.dart';
import '../screens/user/cart_screen.dart';
import '../screens/user/tour_record.dart';
import '../screens/user/user_profile_screen.dart';
import '../utils/constant.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/admin/your_tours.dart';
import '../screens/user/main.dart';

class DrawerWidget extends StatefulWidget {
  final User? user;
  const DrawerWidget({super.key, required this.user});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final UserProfileController userProfileController = Get.find();

  @override
  void initState() {
    super.initState();
    // Gọi hàm fetchUserData khi màn hình được khởi tạo
    userProfileController.fetchUserData(widget.user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Get.height / 25),
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        backgroundColor: AppConstant.appScendoryColor,
        child: Obx(() {
          final userData = userProfileController.userData.value;
          if (userData == null || userData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Wrap(
              runSpacing: 15,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: Text(
                      userData['username'] ?? "No name",
                      style: const TextStyle(color: AppConstant.appTextColor),
                    ),
                    subtitle: Text(
                      "Phone number: " + (userData['phone'] ?? "No phone number"),
                      style: const TextStyle(color: AppConstant.appTextColor),
                    ),
                    leading: GestureDetector(
                      onTap: () {
                        Get.to(() => UserProfileScreen(user: widget.user),
                            arguments: {
                              'userId': widget.user!.uid,
                              'isEditable': true,
                            }); // Chuyển tới UserProfileScreen với userId và isEditable là true
                      },
                      child: Container(
                        child: userData['userImg'] != null
                            ? CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(userData['userImg']!),
                        )
                            : const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage('assets/default_avatar.png'), // Default avatar
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                ),

                const Divider(
                  indent: 10.0,
                  endIndent: 10.0,
                  thickness: 1.5,
                  color: Colors.grey,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: const Text(
                      "Home",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    leading: const Icon(
                      Icons.home,
                      color: AppConstant.appTextColor,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: AppConstant.appTextColor,
                    ),
                    onTap: () {
                      Get.back();
                      Get.to(() => const MainScreen());
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: const Text(
                      "Tours",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    leading: const Icon(
                      Icons.local_mall,
                      color: AppConstant.appTextColor,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: AppConstant.appTextColor,
                    ),
                    onTap: () => Get.to(() => const AllToursScreen()),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: const Text(
                      "Cart",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    leading: const Icon(
                      Icons.shopping_cart,
                      color: AppConstant.appTextColor,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: AppConstant.appTextColor,
                    ),
                    onTap: () => Get.to(() => const CartScreen()),
                  ),
                ),

                // New Padding for Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: const Text(
                      "Messages",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    leading: const Icon(
                      Icons.message,
                      color: AppConstant.appTextColor,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: AppConstant.appTextColor,
                    ),
                    onTap: () => Get.to(() => ChatListScreen()),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: const Text(
                      "Record",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    leading: const Icon(
                      Icons.receipt_long,
                      color: AppConstant.appTextColor,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: AppConstant.appTextColor,
                    ),
                    onTap: () => Get.to(() => TourRecordScreen()),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Obx(() {
                    final userData = userProfileController.userData.value;
                    final bool isAdmin = userData != null ? userData['isAdmin'] ?? false : false;
                    if (isAdmin) {
                      return ListTile(
                        onTap: () {
                          Get.to(() => YourToursScreen());
                        },
                        titleAlignment: ListTileTitleAlignment.center,
                        title: const Text(
                          "Your Tours",
                          style: TextStyle(color: AppConstant.appTextColor),
                        ),
                        leading: const Icon(
                          Icons.tour, // Thay đổi icon ở đây
                          color: AppConstant.appTextColor,
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward,
                          color: AppConstant.appTextColor,
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ListTile(
                    onTap: () async {
                      GoogleSignIn googleSignIn = GoogleSignIn();
                      FirebaseAuth _auth = FirebaseAuth.instance;
                      await _auth.signOut();
                      await googleSignIn.signOut();
                      Get.offAll(() => WelcomeScreen());
                    },
                    titleAlignment: ListTileTitleAlignment.center,
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: AppConstant.appTextColor),
                    ),
                    leading: const Icon(
                      Icons.logout,
                      color: AppConstant.appTextColor,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: AppConstant.appTextColor,
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
