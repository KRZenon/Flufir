import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flufir/screens/user/all_flash_sale.dart';
import 'package:flufir/screens/user/all_tours.dart';
import 'package:flufir/utils/constant.dart';
import 'package:flufir/widgets/all_tours_widget.dart';
import 'package:flufir/widgets/category.dart';
import 'package:flufir/widgets/custom_drawer.dart';
import 'package:flufir/widgets/flash_sale_widget.dart';
import 'package:flufir/widgets/heading_widget.dart';
import 'package:flufir/controllers/user_profile_controller.dart';
import 'package:flufir/widgets/weather_widget.dart';
import '../../controllers/ad_notify_controller.dart';
import '../admin/ad_notify.dart';
import '../admin/create_tour_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final UserProfileController userProfileController = Get.find();
  final NotificationController notificationController = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppConstant.appTextColor),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppConstant.appScendoryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        backgroundColor: AppConstant.appMainColor,
        title: Text(
          AppConstant.appMainName,
          style: const TextStyle(color: AppConstant.appTextColor),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final bool isAdmin = snapshot.data?.get('isAdmin') ?? false;

              if (isAdmin) {
                return Obx(() {
                  return GestureDetector(
                    onTap: () async {
                      await Get.to(() => NotificationScreen());
                      notificationController.hasNewNotification.value = false;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.notifications,
                        color: notificationController.hasNewNotification.value ? Colors.red : Colors.white,
                      ),
                    ),
                  );
                });
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
      drawer: DrawerWidget(user: currentUser),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: Get.height / 90.0,
            ),
            WeatherWidget(),
            CategoryWidget(),
            HeadingWidget(
              headingTitle: "Flash Sale",
              headingSubTitle: "According to your budget",
              onTap: () => Get.to(() => const AllFlashSaleToursScreen()),
              buttonText: "See More >",
            ),
            const FlashSaleWidget(),
            HeadingWidget(
              headingTitle: "All Tours",
              headingSubTitle: "According to your budget",
              onTap: () => Get.to(() => const AllToursScreen()),
              buttonText: "See More >",
            ),
            const AllToursWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CreateTourScreen(user: currentUser)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
