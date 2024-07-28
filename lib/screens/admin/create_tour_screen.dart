import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/screens/admin/your_tours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flufir/controllers/tour_controller.dart';


class CreateTourScreen extends StatefulWidget {
  final User? user;
  const CreateTourScreen({super.key, required this.user});

  @override
  _CreateTourScreenState createState() => _CreateTourScreenState();
}

class _CreateTourScreenState extends State<CreateTourScreen> {
  final TourController addTourController = Get.put(TourController());
  final TextEditingController tourNameController = TextEditingController();
  final TextEditingController tourDescriptionController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController fullPriceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  XFile? _pickedFile;

  Future<void> _checkPermissionAndPickImage() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    final status = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    } else if (status.isPermanentlyDenied) {
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
        title: const Text('Create Tour'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _checkPermissionAndPickImage,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: _pickedFile != null
                      ? Image.file(
                    File(_pickedFile!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.add_a_photo, size: 50), // Hiển thị icon để thêm hình ảnh
                ),
              ),
              TextFormField(
                controller: tourNameController,
                decoration: const InputDecoration(labelText: 'Tour Name'),
              ),
              TextFormField(
                controller: tourDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: salePriceController,
                decoration: const InputDecoration(labelText: 'Sale Price'),
              ),
              TextFormField(
                controller: fullPriceController,
                decoration: const InputDecoration(labelText: 'Full Price'),
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: streetController,
                decoration: const InputDecoration(labelText: 'Street'),
              ),
              TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              TextFormField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  // Check if image is picked
                  if (_pickedFile == null) {
                    Get.snackbar('Error', 'Please select an image');
                    return;
                  }

                  bool success = await addTourController.addTour(
                    widget.user!.uid,
                    tourNameController.text,
                    tourDescriptionController.text,
                    salePriceController.text,
                    fullPriceController.text,
                    addressController.text,
                    streetController.text,
                    cityController.text,
                    durationController.text,
                    File(_pickedFile!.path),
                  );

                  if (success) {
                    Get.snackbar('Success', 'Tour created successfully');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => YourToursScreen()),
                    );
                  } else {
                    Get.snackbar('Error', 'Failed to create tour');
                  }
                },
                child: const Text('Create Tour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
