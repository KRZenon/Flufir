import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../utils/constant.dart';
import '../../utils/currency_utils.dart';
import '../user/user_profile_screen.dart';


class TourRevenueScreen extends StatefulWidget {
  final String tourId;

  const TourRevenueScreen({super.key, required this.tourId});

  @override
  _TourRevenueScreenState createState() => _TourRevenueScreenState();
}

class _TourRevenueScreenState extends State<TourRevenueScreen> {
  late Future<Map<String, dynamic>> revenueDataFuture;

  @override
  void initState() {
    super.initState();
    revenueDataFuture = _getRevenueData();
  }

  Future<Map<String, dynamic>> _getRevenueData() async {
    try {
      final ordersQuery = await FirebaseFirestore.instance
          .collectionGroup('userOrders')
          .where('tourId', isEqualTo: widget.tourId)
          .get();

      double totalRevenue = 0;
      int totalPurchases = ordersQuery.docs.length;
      List<Map<String, dynamic>> userList = [];

      for (var order in ordersQuery.docs) {
        var data = order.data();
        totalRevenue += double.parse(data['tourTotalPrice']);

        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(data['userId'])
            .get();
        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          userList.add({
            'userId': data['userId'], // Thêm userId vào userList
            'user': UserModel.fromMap(userData),
            'purchaseTime': (data['createdAt'] as Timestamp).toDate(),
          });
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'totalPurchases': totalPurchases,
        'userList': userList,
      };
    } catch (e) {
      // Print the error to the console
      print('Error: $e');
      // Return an empty map if there's an error
      return {
        'totalRevenue': 0.0,
        'totalPurchases': 0,
        'userList': <Map<String, dynamic>>[],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Tour Revenue', style: TextStyle(color: AppConstant.appTextColor)),
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
            final List<Map<String, dynamic>> userList = List<Map<String, dynamic>>.from(revenueData['userList']);

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
                      'Users bought this tour',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        final user = userList[index]['user'] as UserModel;
                        final userId = userList[index]['userId'] as String; // Lấy userId từ userList
                        final purchaseTime = userList[index]['purchaseTime'] as DateTime;

                        return ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfileScreen(user: FirebaseAuth.instance.currentUser),
                                  settings: RouteSettings(arguments: {
                                    'userId': userId,
                                    'isEditable': false,
                                  }), // Truyền userId và isEditable
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundImage: user.userImg.isNotEmpty
                                  ? NetworkImage(user.userImg)
                                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
                              child: user.userImg.isEmpty ? Text(user.username.substring(0, 1).toUpperCase()) : null,
                            ),
                          ),
                          title: Text(user.username),
                          subtitle: Text(
                            'Purchased at: ${purchaseTime.toLocal().toString().substring(0, 16)}', // YYYY-MM-DD HH:MM
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(user: FirebaseAuth.instance.currentUser),
                                settings: RouteSettings(arguments: {
                                  'userId': userId,
                                  'isEditable': false,
                                }), // Truyền userId và isEditable
                              ),
                            );
                          },
                        );
                      },
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
