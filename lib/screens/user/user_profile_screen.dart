import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flufir/controllers/user_profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/constant.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final User? user;

  const UserProfileScreen({super.key, required this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileController userProfileController = Get.find();
  late String userId;
  late bool isEditable;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>; // Lấy arguments từ RouteSettings
    userId = args['userId'];
    isEditable = args['isEditable'];
    userProfileController.fetchUserData(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile', style: TextStyle(color: AppConstant.appMainColor)),
        iconTheme: const IconThemeData(color: AppConstant.appMainColor),
      ),
      body: Obx(() {
        final userData = userProfileController.userData.value;

        if (userData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 20.0),
                child: userData['userImg'] != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userData['userImg']),
                )
                    : const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/default_avatar.png'), // Default avatar
                  child: Icon(Icons.person),
                ),
              ),
              Text('Username: ${userData['username']}'),
              const SizedBox(height: 20.0),
              Text('Email: ${userData['email']}'),
              const SizedBox(height: 20.0),
              Text('Phone: ${userData['phone']}'),
              const SizedBox(height: 20.0),
              Text('Address: ${userData['userAddress']}, ${userData['street']}, ${userData['city']}'),
              const SizedBox(height: 20.0),
              if (isEditable) // Chỉ hiển thị nút chỉnh sửa nếu isEditable là true
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => EditProfileScreen(user: widget.user)); // Sử dụng widget.user
                  },
                  child: const Center(child:  Text('Edit Profile')),
                ),
            ],
          ),
        );
      }),
    );
  }
}
