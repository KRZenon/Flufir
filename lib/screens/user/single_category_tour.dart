import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:flufir/models/tour_model.dart';
import 'package:flufir/screens/user/tour_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flufir/utils/constant.dart';
import 'package:flufir/utils/currency_utils.dart'; // Import currency_utils.dart for formatting prices

class SingleCategoryTourScreen extends StatefulWidget {
  final String selectedCity;

  const SingleCategoryTourScreen({super.key, required this.selectedCity});

  @override
  State<SingleCategoryTourScreen> createState() => _SingleCategoryTourScreenState();
}

class _SingleCategoryTourScreenState extends State<SingleCategoryTourScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: Text("All Tours in ${widget.selectedCity}", style: const TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('tours')
            .where('city', isEqualTo: widget.selectedCity)
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
            return Center(
              child: Text("No tours found in ${widget.selectedCity}"),
            );
          }

          if (snapshot.data != null) {
            return GridView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                childAspectRatio: 0.75, // Adjust this value to fit content
              ),
              itemBuilder: (context, index) {
                final tourData = snapshot.data!.docs[index];
                final data = tourData.data() as Map<String, dynamic>;
                final tourModel = TourModel.fromMap(data);

                return GestureDetector(
                  onTap: () => Get.to(() => TourDetailsScreen(tourModel: tourModel)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FillImageCard(
                          borderRadius: 20.0,
                          width: Get.width / 2.3,
                          heightImage: Get.height / 6,
                          imageProvider: CachedNetworkImageProvider(
                            tourModel.tourImages.isNotEmpty
                                ? tourModel.tourImages[0]
                                : 'https://via.placeholder.com/150',
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
                            child: Text(
                              "Price: ${formatCurrency(tourModel.isSale ? tourModel.salePrice : tourModel.fullPrice)}",
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ),
                        ),
                      ],
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
