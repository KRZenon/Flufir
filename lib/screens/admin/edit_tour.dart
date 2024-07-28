import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/controllers/tour_controller.dart';
import 'package:flufir/models/tour_model.dart';

class EditTourScreen extends StatefulWidget {
  final TourModel tourModel;
  const EditTourScreen({super.key, required this.tourModel});

  @override
  _EditTourScreenState createState() => _EditTourScreenState();
}

class _EditTourScreenState extends State<EditTourScreen> {
  final TourController _tourController = Get.find<TourController>();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;

  late TextEditingController _tourNameController;
  late TextEditingController _tourDesController;
  late TextEditingController _salePriceController;
  late TextEditingController _fullPriceController;
  late TextEditingController _addressController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _tourNameController = TextEditingController(text: widget.tourModel.tourName);
    _tourDesController = TextEditingController(text: widget.tourModel.tourDescription);
    _salePriceController = TextEditingController(text: widget.tourModel.salePrice);
    _fullPriceController = TextEditingController(text: widget.tourModel.fullPrice);
    _addressController = TextEditingController(text: widget.tourModel.tourAddress);
    _streetController = TextEditingController(text: widget.tourModel.tourStreet);
    _cityController = TextEditingController(text: widget.tourModel.tourCity);
    _durationController = TextEditingController(text: widget.tourModel.duration);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      bool success = await _tourController.updateTour(
        widget.tourModel.tourId,
        _tourNameController.text,
        _tourDesController.text,
        _salePriceController.text,
        _fullPriceController.text,
        _addressController.text,
        _streetController.text,
        _cityController.text,
        _durationController.text,
        _imageFile,
      );

      if (success) {
        Get.back();
        Get.snackbar('Success', 'Tour updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update tour');
      }
    }
  }

  Future<void> _deleteTour() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this tour?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                bool success = await _tourController.deleteTour(widget.tourModel.tourId, currentUser!.uid);
                if (success) {
                  Get.back();
                  Get.snackbar('Success', 'Tour deleted successfully');
                } else {
                  Get.snackbar('Error', 'Failed to delete tour');
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tourNameController.dispose();
    _tourDesController.dispose();
    _salePriceController.dispose();
    _fullPriceController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Tour'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _imageFile == null
                      ? Image.network(
                    widget.tourModel.tourImages.isNotEmpty ? widget.tourModel.tourImages[0] : '',
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    _imageFile!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                TextFormField(
                  controller: _tourNameController,
                  decoration: const InputDecoration(labelText: 'Tour Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter a tour name' : null,
                ),
                TextFormField(
                  controller: _tourDesController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                ),
                TextFormField(
                  controller: _salePriceController,
                  decoration: const InputDecoration(labelText: 'Sale Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _fullPriceController,
                  decoration: const InputDecoration(labelText: 'Full Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter a full price' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
                ),
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(labelText: 'Street'),
                  validator: (value) => value!.isEmpty ? 'Please enter a street' : null,
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                ),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Duration'),
                  validator: (value) => value!.isEmpty ? 'Please enter a duration' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _deleteTour,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Background color
                  ),
                  child: const Text('Delete Tour'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
