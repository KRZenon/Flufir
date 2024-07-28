import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/constant.dart';
import '../../models/cart_model.dart';
import 'place_order.dart';
import 'package:flufir/utils/currency_utils.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Cart Screen', style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .doc(user!.uid)
            .collection('cartOrders')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: Get.height / 5,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No products found!"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final tourData = snapshot.data!.docs[index].data();
              CartModel cartModel = CartModel(
                tourId: tourData['tourId'] ?? '', // Provide default value
                tourName: tourData['tourName'] ?? '',
                tourDescription: tourData['tourDescription'] ?? '',
                tourAddress: tourData['tourAddress'] ?? '',
                tourStreet: tourData['tourStreet'] ?? '',
                tourCity: tourData['tourCity'] ?? '',
                fullPrice: tourData['fullPrice'] ?? '',
                salePrice: tourData['salePrice'] ?? '',
                isSale: tourData['isSale'] ?? false,
                tourImages: List<String>.from(tourData['tourImages'] ?? []),
                duration: tourData['duration'] ?? '',
                createdAt: tourData['createdAt'] ?? Timestamp.now(),
                updatedAt: tourData['updatedAt'] ?? Timestamp.now(),
                tourQuantity: tourData['tourQuantity'] ?? 0,
                tourTotalPrice: tourData['tourTotalPrice'] ?? 0.0,
              );

              return SwipeActionCell(
                key: ObjectKey(cartModel.tourId),
                trailingActions: [
                  SwipeAction(
                    title: "Delete",
                    forceAlignmentToBoundary: true,
                    performsFirstActionWithFullSwipe: true,
                    onTap: (CompletionHandler handler) async {
                      print('deleted');
                      await FirebaseFirestore.instance
                          .collection('cart')
                          .doc(user!.uid)
                          .collection('cartOrders')
                          .doc(cartModel.tourId)
                          .delete();
                      cartController.fetchCartData(); // Update total price
                    },
                  )
                ],
                child: Card(
                  elevation: 5,
                  color: AppConstant.appTextColor,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstant.appMainColor,
                      backgroundImage: NetworkImage(cartModel.tourImages.isNotEmpty ? cartModel.tourImages[0] : ''),
                    ),
                    title: Text(cartModel.tourName),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(formatCurrencyDouble(cartModel.tourTotalPrice)),
                        SizedBox(
                          width: Get.width / 20.0,
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.to(() => CheckOutScreen(cartModel: cartModel));
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
