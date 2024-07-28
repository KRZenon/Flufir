import 'package:flufir/utils/currency_utils.dart';
import 'package:image_card/image_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flufir/models/tour_model.dart';
import 'package:flufir/screens/user/tour_details.dart';
import 'package:flufir/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllFlashSaleToursScreen extends StatefulWidget {
  const AllFlashSaleToursScreen({super.key});

  @override
  State<AllFlashSaleToursScreen> createState() =>
      _AllFlashSaleToursScreenState();
}

class _AllFlashSaleToursScreenState extends State<AllFlashSaleToursScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text("All Flash Sale Tours",style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color:  AppConstant.appStatusBarColor),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('tours')
            .where('isSale', isEqualTo: true)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: Get.height / 5,
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No tours found!"),
            );
          }

          if (snapshot.data != null) {
            return GridView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 0.80,
              ),
              itemBuilder: (context, index) {
                final tourData = snapshot.data!.docs[index];
                final data = tourData.data() as Map<String, dynamic>;
                final tourModel = TourModel.fromMap(data);

                return GestureDetector(
                  onTap: () {
                    Get.to(() => TourDetailsScreen(tourModel: tourModel));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FillImageCard(
                      borderRadius: 20.0,
                      width: Get.width / 2.3,
                      heightImage: Get.height / 6,
                      imageProvider: CachedNetworkImageProvider(
                        tourModel.tourImages.isNotEmpty ? tourModel.tourImages[0] : '',
                      ),
                      title: Center(
                        child: Text(
                          tourModel.tourName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ),
                      footer: Center(
                        child: Text("Price: ${formatCurrency(tourModel.isSale ? tourModel.salePrice : tourModel.fullPrice)}"),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Container();
        },
      ),
    );
  }
}
