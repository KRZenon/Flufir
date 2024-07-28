import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flufir/models/tour_model.dart';
import 'package:flufir/screens/user/cart_screen.dart';
import 'package:flufir/screens/admin/edit_tour.dart';
import 'package:flufir/utils/constant.dart';
import 'package:flufir/utils/currency_utils.dart';
import 'package:flufir/controllers/chat_controller.dart';
import 'package:flufir/widgets/rating_widget.dart';
import 'package:flufir/widgets/comment_widget.dart';
import '../../models/cart_model.dart';
import 'chat_screen.dart';

class TourDetailsScreen extends StatefulWidget {
  final TourModel tourModel;

  const TourDetailsScreen({super.key, required this.tourModel});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  late User? user;
  String? contactNumber;
  final ChatController chatController = Get.put(ChatController());

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchContactNumber();
  }

  Future<void> _fetchContactNumber() async {
    final userData = await FirebaseFirestore.instance.collection('users').doc(widget.tourModel.uId).get();
    if (userData.exists) {
      setState(() {
        contactNumber = userData['phone'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = user?.uid == widget.tourModel.uId;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
        backgroundColor: AppConstant.appMainColor,
        title: const Text(
          "Tour Details",
          style: TextStyle(color: AppConstant.appTextColor),
        ),
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => const CartScreen()),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topLeft,
              children: [
                Container(
                  height: 200, // Set desired height for the tour image banner
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.tourModel.tourImages.isNotEmpty
                          ? widget.tourModel.tourImages[0]
                          : ''), // Use the first tour image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tourModel.tourName,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SingleChildScrollView(
                    child: Text(
                      widget.tourModel.tourDescription,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  RatingWidget(tourId: widget.tourModel.tourId), // Add RatingWidget here
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 5),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          widget.tourModel.isSale && widget.tourModel.salePrice.isNotEmpty
                              ? "Sale: ${formatCurrency(widget.tourModel.salePrice)}"
                              : "Price: ${formatCurrency(widget.tourModel.fullPrice)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Address: ${widget.tourModel.tourAddress.isNotEmpty ? widget.tourModel.tourAddress : 'N/A'}, ${widget.tourModel.tourStreet.isNotEmpty ? widget.tourModel.tourStreet : 'N/A'}, ${widget.tourModel.tourCity.isNotEmpty ? widget.tourModel.tourCity : 'N/A'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Contact: ${contactNumber ?? 'Loading...'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () async {
                            String chatId = await chatController.createChat(widget.tourModel.uId);
                            Get.to(() => ChatScreen(recipientId: widget.tourModel.uId, chatId: chatId));
                            print("Chat now");
                                                    },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Chat now",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isOwner)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.to(() => EditTourScreen(tourModel: widget.tourModel));
                          },
                          child: const Text("Edit"),
                        ),
                      ],
                    ),
                  const SizedBox(width: 20.0),
                  Material(
                    child: Container(
                      width: Get.width / 3.0,
                      height: Get.height / 16,
                      decoration: BoxDecoration(
                        color: AppConstant.appScendoryColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextButton(
                        child: const Text(
                          "Add to cart",
                          style: TextStyle(color: AppConstant.appTextColor),
                        ),
                        onPressed: () async {
                          if (user != null) {
                            await checkProductExistence(uId: user!.uid);
                          } else {
                            Get.snackbar("Error", "User not logged in");
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CommentWidget(tourId: widget.tourModel.tourId), // Add CommentWidget here
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkProductExistence({
    required String uId,
    int quantityIncrement = 1,
  }) async {
    final DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(uId)
        .collection('cartOrders')
        .doc(widget.tourModel.tourId);

    DocumentSnapshot snapshot = await documentReference.get();

    if (snapshot.exists) {
      int currentQuantity = snapshot['tourQuantity'];
      int updatedQuantity = currentQuantity + quantityIncrement;

      double totalPrice = double.parse(widget.tourModel.isSale
          ? widget.tourModel.salePrice
          : widget.tourModel.fullPrice) * updatedQuantity;

      await documentReference.update({
        'tourQuantity': updatedQuantity,
        'tourTotalPrice': totalPrice,
      });
      Get.snackbar("Success", "This tour is in your cart");
      print("Product exists");
    } else {
      await FirebaseFirestore.instance.collection('cart').doc(uId).set({
        'uId': uId,
        'createdAt': Timestamp.now(),
      });

      CartModel cartModel = CartModel(
        tourId: widget.tourModel.tourId,
        tourName: widget.tourModel.tourName,
        salePrice: widget.tourModel.salePrice,
        fullPrice: widget.tourModel.fullPrice,
        tourImages: widget.tourModel.tourImages,
        duration: widget.tourModel.duration,
        isSale: widget.tourModel.isSale,
        tourDescription: widget.tourModel.tourDescription,
        tourAddress: widget.tourModel.tourAddress,
        tourStreet: widget.tourModel.tourStreet,
        tourCity: widget.tourModel.tourCity,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        tourQuantity: 1,
        tourTotalPrice: double.parse(widget.tourModel.isSale
            ? widget.tourModel.salePrice
            : widget.tourModel.fullPrice),
      );

      await documentReference.set(cartModel.toMap());
      Get.snackbar("Success", "This tour is in your cart");
      print("Product added");
    }
  }
}
