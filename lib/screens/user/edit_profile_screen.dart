import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/screens/user/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flufir/controllers/user_profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../utils/constant.dart';

class EditProfileScreen extends StatefulWidget {
  final User? user;
  const EditProfileScreen({super.key, required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  XFile? _pickedFile;
  String? _avatarImage; // Store avatar image URL from Firestore

  @override
  void initState() {
    super.initState();
    // Fetch user data when the screen is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userProfileController = Get.find<UserProfileController>();
      await userProfileController.fetchUserData(widget.user!.uid);
      final userData = userProfileController.userData.value;

      // Update text fields with user data (if available)
      usernameController.text = userData['username'] ?? '';
      emailController.text = userData['email'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      addressController.text = userData['userAddress'] ?? '';
      streetController.text = userData['street'] ?? '';
      cityController.text = userData['city'] ?? '';
      countryController.text = userData['country'] ?? '';

      // Update avatar image from Firestore (if available)
      setState(() {
        _avatarImage = userData['userImg'];
      });
    } catch (error) {
      Get.snackbar('Error', 'Failed to fetch user data: $error');
    }
  }

  Future<void> _checkPermissionAndPickImage() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    // Check storage permission
    final status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (status.isGranted) {
      // If permission granted, allow user to pick an image
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    } else if (status.isPermanentlyDenied) {
      // If permission permanently denied, prompt user to open settings
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Please allow access to storage to pick an image in your device settings.'),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      // If permission denied, prompt user to grant permission
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text('Please allow access to storage to pick an image.'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color:  AppConstant.appStatusBarColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display selected image (if any)
            GestureDetector(
              onTap: _checkPermissionAndPickImage,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 20.0),
                child: _pickedFile != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(File(_pickedFile!.path)),
                )
                    : _avatarImage != null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_avatarImage!),
                )
                    : const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/default_avatar.png'), // Default avatar
                  child: Icon(Icons.person),
                ),
              ),
            ),

            const Text('Username'),
            TextField(controller: usernameController),
            const SizedBox(height: 20.0),
            const Text('Email'),
            TextField(controller: emailController),
            const SizedBox(height: 20.0),
            const Text('Phone'),
            TextField(controller: phoneController),
            const SizedBox(height: 20.0),
            const Text('Address'),
            TextField(controller: addressController),
            const SizedBox(height: 20.0),
            const Text('Street'),
            TextField(controller: streetController),
            const SizedBox(height: 20.0),
            const Text('City'),
            TextField(controller: cityController),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final success = await Get.find<UserProfileController>().updateUserProfile(
                  widget.user!.uid,
                  usernameController.text,
                  emailController.text,
                  phoneController.text,
                  addressController.text,
                  streetController.text,
                  cityController.text,
                  _pickedFile != null ? File(_pickedFile!.path) : null,
                );

                if (success) {
                  Get.snackbar('Success', 'Profile updated successfully');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  );
                } else {
                  Get.snackbar('Error', 'Failed to update profile');
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
