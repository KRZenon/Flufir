import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../utils/constant.dart';
import '../../../utils/currency_utils.dart';
import 'revenue_screen.dart';

class AllToursRevenueScreen extends StatefulWidget {
  @override
  _AllToursRevenueScreenState createState() => _AllToursRevenueScreenState();
}

class _AllToursRevenueScreenState extends State<AllToursRevenueScreen> {
  late Future<Map<String, dynamic>> revenueDataFuture;

  @override
  void initState() {
    super.initState();
    revenueDataFuture = _getRevenueData();
  }

  Future<Map<String, dynamic>> _getRevenueData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final userId = user.uid;

      // Fetch all tours created by the current user
      final toursQuery = await FirebaseFirestore.instance
          .collection('tours')
          .where('uId', isEqualTo: userId)
          .get();

      double totalRevenue = 0;
      int totalPurchases = 0;
      List<Map<String, dynamic>> tourList = [];

      for (var tour in toursQuery.docs) {
        final tourData = tour.data();
        final tourId = tourData['tourId'] ?? '';
        final tourName = tourData['tourName'] ?? 'Unknown Tour';
        final tourImage = tourData['tourImages']?.isNotEmpty == true ? tourData['tourImages'][0] : '';

        // Fetch all orders for the current tour
        final ordersQuery = await FirebaseFirestore.instance
            .collectionGroup('userOrders')
            .where('tourId', isEqualTo: tourId)
            .get();

        final int tourPurchases = ordersQuery.docs.length;
        totalPurchases += tourPurchases;

        for (var order in ordersQuery.docs) {
          var data = order.data();
          totalRevenue += double.parse(data['tourTotalPrice']);
        }

        if (tourPurchases > 0) {
          tourList.add({
            'tourId': tourId,
            'tourName': tourName,
            'tourImage': tourImage,
            'tourPurchases': tourPurchases,
          });
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'totalPurchases': totalPurchases,
        'tourList': tourList,
      };
    } catch (e) {
      // Print the error to the console
      print('Error: $e');
      // Return an empty map if there's an error
      return {
        'totalRevenue': 0.0,
        'totalPurchases': 0,
        'tourList': <Map<String, dynamic>>[],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('All Tours Revenue', style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: revenueDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Print the error to the console
            print('Error in FutureBuilder: ${snapshot.error}');
            return const Center(
              child: Text('An error occurred. Please check the console for details.'),
            );
          } else {
            final revenueData = snapshot.data!;
            final double totalRevenue = revenueData['totalRevenue'];
            final int totalPurchases = revenueData['totalPurchases'];
            final List<Map<String, dynamic>> tourList = List<Map<String, dynamic>>.from(revenueData['tourList']);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Revenue: ${formatCurrencyDouble(totalRevenue)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Total Purchases: $totalPurchases',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(), // Đường cắt ngang
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Tours that have been bought',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: tourList.isNotEmpty
                        ? ListView.builder(
                      itemCount: tourList.length,
                      itemBuilder: (context, index) {
                        final tourName = tourList[index]['tourName'] as String;
                        final tourId = tourList[index]['tourId'] as String;
                        final tourImage = tourList[index]['tourImage'] as String;
                        final tourPurchases = tourList[index]['tourPurchases'] as int;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(tourImage),
                          ),
                          title: Text(tourName),
                          subtitle: Text('Total Purchases: $tourPurchases'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TourRevenueScreen(tourId: tourId),
                              ),
                            );
                          },
                        );
                      },
                    )
                        : const Center(
                      child: Text('No tours have been bought at this time.'),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysDifference = difference(firstDayOfYear).inDays;
    return (daysDifference / 7).ceil();
  }
}
