import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/cart_model.dart';

class CartController extends GetxController {
  RxDouble totalPrice = 0.0.obs;
  RxInt totalQuantity = 0.obs;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchCartData();
  }

  void fetchCartData() async {
    if (user != null) {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('cart')
          .doc(user!.uid)
          .collection('cartOrders')
          .get();

      double sum = 0.0;
      int quantitySum = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data != null && data.containsKey('tourTotalPrice')) {
          sum += (data['tourTotalPrice'] as num).toDouble();
          quantitySum += (data['tourQuantity'] as num).toInt();
        }
      }
      totalPrice.value = sum;
      totalQuantity.value = quantitySum;
    }
  }

  Future<void> updateCartQuantity(String tourId, int quantity) async {
    if (user != null) {
      final DocumentReference<Map<String, dynamic>> documentReference = FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('cartOrders')
          .doc(tourId);

      final DocumentSnapshot<Map<String, dynamic>> snapshot = await documentReference.get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        await documentReference.update({
          'tourQuantity': quantity,
          'tourTotalPrice': data['tourTotalPrice'] / data['tourQuantity'] * quantity,
        });
        fetchCartData(); // Update total price and quantity
      }
    }
  }

  Future<void> removeCartItem(String tourId) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('cartOrders')
          .doc(tourId)
          .delete();
      fetchCartData(); // Update total price and quantity
    }
  }

  Future<CartModel?> getCartItemById(String tourId) async {
    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('cartOrders')
          .doc(tourId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          return CartModel.fromMap(data);
        }
      }
    }
    return null;
  }

  void clearCart() async {
    if (user != null) {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('cartOrders')
          .get();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      fetchCartData(); // Clear total price and quantity
    }
  }
}
