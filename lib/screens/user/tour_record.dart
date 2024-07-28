import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/screens/user/order_success.dart';
import 'package:flufir/utils/constant.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:flufir/utils/currency_utils.dart';

class TourRecordScreen extends StatefulWidget {
  const TourRecordScreen({super.key});

  @override
  _TourRecordScreenState createState() => _TourRecordScreenState();
}

class _TourRecordScreenState extends State<TourRecordScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<String> _getAdminId(String tourId) async {
    final tourSnapshot = await FirebaseFirestore.instance.collection('tours').doc(tourId).get();
    if (tourSnapshot.exists) {
      return tourSnapshot.data()?['uId'] ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Tour Records', style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(user!.uid)
            .collection('userOrders')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No tour records found!"),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final tourData = snapshot.data!.docs[index].data();
              final List<dynamic>? tourImages = tourData['tourImages'] as List<dynamic>?;

              return FutureBuilder<String>(
                future: _getAdminId(tourData['tourId']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  String adminId = snapshot.data!;

                  return ListTile(
                    leading: FillImageCard(
                      borderRadius: 20.0,
                      width: Get.width / 3.2,
                      heightImage: Get.height / 24.8,
                      imageProvider: CachedNetworkImageProvider(
                        tourImages != null && tourImages.isNotEmpty ? tourImages[0] : '',
                      ),
                    ),
                    title: Text(tourData['tourName']),
                    subtitle: Text('Total Price: ${formatCurrency(tourData['fullPrice'])}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSuccessScreen(
                            tourId: tourData['tourId'],
                            tourName: tourData['tourName'],
                            tourTotalPrice: tourData['fullPrice'],
                            tourImage: tourImages != null && tourImages.isNotEmpty ? tourImages[0] : '',
                            tourAddress: tourData['tourAddress'],
                            tourStreet: tourData['tourStreet'],
                            tourCity: tourData['tourCity'],
                            adminId: adminId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
