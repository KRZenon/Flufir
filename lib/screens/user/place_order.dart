import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/screens/user/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flufir/controllers/cart_controller.dart';
import 'package:flufir/models/cart_model.dart';
import 'package:flufir/utils/constant.dart';
import 'package:flufir/utils/currency_utils.dart';
import '../../controllers/ad_notify_controller.dart';
import 'order_success.dart';

class CheckOutScreen extends StatefulWidget {
  final CartModel cartModel;

  const CheckOutScreen({super.key, required this.cartModel});

  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final CartController cartController = Get.find();
  final NotificationController notificationController = Get.find();
  final User? user = FirebaseAuth.instance.currentUser;
  int quantity = 1;

  Future<String?> _getAdminId(String tourId) async {
    final tourSnapshot = await FirebaseFirestore.instance.collection('tours').doc(tourId).get();
    if (tourSnapshot.exists) {
      return tourSnapshot.data()?['uId'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Place Order Screen', style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.cartModel.tourImages.isNotEmpty ? widget.cartModel.tourImages[0] : '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.cartModel.tourName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.cartModel.tourDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.cartModel.isSale
                        ? 'Full Price: ${formatCurrency(widget.cartModel.fullPrice)}'
                        : '',
                    style: const TextStyle(decoration: TextDecoration.lineThrough),
                  ),
                  Text(
                    widget.cartModel.isSale
                        ? 'Sale Price: ${formatCurrency(widget.cartModel.salePrice)}'
                        : 'Price: ${formatCurrency(widget.cartModel.fullPrice)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  Text('Duration: ${widget.cartModel.duration}'),
                  const SizedBox(height: 8.0),
                  Text('Address: ${widget.cartModel.tourAddress}, ${widget.cartModel.tourStreet}, ${widget.cartModel.tourCity}'),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        child: const CircleAvatar(
                          radius: 14.0,
                          backgroundColor: AppConstant.appTextColor,
                          child: Text('-'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Quantity: $quantity',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        child: const CircleAvatar(
                          radius: 14.0,
                          backgroundColor: AppConstant.appTextColor,
                          child: Text('+'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Total Price: ${formatCurrency(widget.cartModel.isSale ? (int.parse(widget.cartModel.salePrice) * quantity).toString() : (int.parse(widget.cartModel.fullPrice) * quantity).toString())}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Hủy tour
                    cartController.removeCartItem(widget.cartModel.tourId);
                    Get.snackbar("Success", "Tour has been cancelled successfully",
                        snackPosition: SnackPosition.BOTTOM);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  child: const Text('Cancel Tour'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Get admin ID
                    String? adminId = await _getAdminId(widget.cartModel.tourId);
                    if (adminId == null) {
                      // Handle error
                      Get.snackbar("Error", "Failed to get admin ID",
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }

                    // Check out
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(user!.uid)
                        .collection('userOrders')
                        .add({
                      'tourId': widget.cartModel.tourId,
                      'tourName': widget.cartModel.tourName,
                      'tourDescription': widget.cartModel.tourDescription,
                      'tourAddress': widget.cartModel.tourAddress,
                      'tourStreet': widget.cartModel.tourStreet,
                      'tourCity': widget.cartModel.tourCity,
                      'fullPrice': widget.cartModel.fullPrice,
                      'salePrice': widget.cartModel.salePrice,
                      'isSale': widget.cartModel.isSale,
                      'tourImages': widget.cartModel.tourImages,
                      'duration': widget.cartModel.duration,
                      'tourQuantity': quantity,
                      'tourTotalPrice': widget.cartModel.isSale
                          ? (int.parse(widget.cartModel.salePrice) * quantity).toString()
                          : (int.parse(widget.cartModel.fullPrice) * quantity).toString(),
                      'createdAt': Timestamp.now(),
                      'adminId': adminId, // Add adminId here
                      'userId': user!.uid // Add userId here
                    });

                    // Add notification to Firestore
                    await notificationController.addNotification(
                      adminId: adminId,
                      userId: user!.uid,
                      tourId: widget.cartModel.tourId,
                      message: 'User ${user?.email ?? 'unknown'} has purchased your tour: ${widget.cartModel.tourName}',
                      tourImg: widget.cartModel.tourImages.isNotEmpty ? widget.cartModel.tourImages[0] : '',
                    );

                    await cartController.removeCartItem(widget.cartModel.tourId);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderSuccessScreen(
                          tourId: widget.cartModel.tourId,
                          tourName: widget.cartModel.tourName,
                          tourTotalPrice: widget.cartModel.isSale
                              ? (int.parse(widget.cartModel.salePrice) * quantity).toString()
                              : (int.parse(widget.cartModel.fullPrice) * quantity).toString(),
                          tourImage: widget.cartModel.tourImages.isNotEmpty ? widget.cartModel.tourImages[0] : '',
                          tourAddress: widget.cartModel.tourAddress,
                          tourStreet: widget.cartModel.tourStreet,
                          tourCity: widget.cartModel.tourCity,
                          adminId: adminId,  // Pass admin ID
                        ),
                      ),
                    );
                  },
                  child: const Text('Place Order'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
