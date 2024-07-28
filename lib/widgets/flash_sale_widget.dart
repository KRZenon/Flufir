import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flufir/models/tour_model.dart';
import 'package:flufir/screens/user/tour_details.dart';
import 'package:flufir/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_card/image_card.dart';
import 'package:flufir/utils/currency_utils.dart';

class FlashSaleWidget extends StatelessWidget {
  const FlashSaleWidget({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
          return SizedBox(
            height: Get.height / 5,
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final tourData = snapshot.data!.docs[index];
                final data = tourData.data() as Map<String, dynamic>;
                final tourModel = TourModel.fromMap(data);

                return Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.to(() =>
                          TourDetailsScreen(tourModel: tourModel)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: FillImageCard(
                          borderRadius: 20.0,
                          width: Get.width / 3.5,
                          heightImage: Get.height / 12,
                          imageProvider: CachedNetworkImageProvider(
                            tourModel.tourImages.isNotEmpty
                                ? tourModel.tourImages[0]
                                : 'https://via.placeholder.com/150',
                          ),
                          title: Center(
                            child: Text(
                              tourModel.tourName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10.0),
                            ),
                          ),
                          footer: Column(
                            children: [
                              Text(
                                "Price ${formatCurrency(tourModel.salePrice)}",
                                style: const TextStyle(fontSize: 10.0),
                              ),
                              const SizedBox(
                                width: 2.0,
                              ),
                              Text(
                                formatCurrency(tourModel.fullPrice),
                                style: const TextStyle(
                                  fontSize: 10.0,
                                  color: AppConstant.appScendoryColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }

        return Container();
      },
    );
  }
}
