import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flufir/screens/user/tour_details.dart';
import 'package:flufir/screens/user/main.dart';
import 'package:flufir/utils/constant.dart';
import '../../controllers/ad_notify_controller.dart';
import '../../models/tour_model.dart';
import 'package:flufir/utils/currency_utils.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String tourName;
  final String tourTotalPrice;
  final String tourImage;
  final String tourAddress;
  final String tourStreet;
  final String tourCity;
  final String tourId;
  final String adminId;

  const OrderSuccessScreen({
    super.key,
    required this.tourName,
    required this.tourTotalPrice,
    required this.tourImage,
    required this.tourAddress,
    required this.tourStreet,
    required this.tourCity,
    required this.tourId,
    required this.adminId,
  });

  Future<void> _launchMapsUrl(String address) async {
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}');
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController = Get.put(NotificationController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Order Success', style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              tourImage,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16.0),
            Text(
              tourName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Total Price: ${formatCurrency(tourTotalPrice)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Address: $tourAddress, $tourStreet, $tourCity',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: AppConstant.appMainColor),
                  onPressed: () {
                    final address = '$tourAddress, $tourStreet, $tourCity';
                    _launchMapsUrl(address);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
              child: const Text('Confirm'),
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () async {
                final tourSnapshot = await FirebaseFirestore.instance.collection('tours').doc(tourId).get();
                final tourData = tourSnapshot.data();

                if (tourData != null && tourData['tourId'] == tourId) {
                  final tourModel = TourModel.fromMap(tourData);

                  try {
                    // Add notification after order success
                    await notificationController.addNotification(
                      adminId: adminId,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                      tourId: tourId,
                      message: 'A new order has been placed for $tourName',
                      tourImg: tourImage,
                    );
                    print("Notification added successfully");
                  } catch (e) {
                    print("Error adding notification: $e");
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TourDetailsScreen(tourModel: tourModel)),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Tour details not found!'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Tour Details'),
            ),
          ],
        ),
      ),
    );
  }
}
