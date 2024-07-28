import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flufir/utils/constant.dart';

class NotificationDetailScreen extends StatelessWidget {
  final String userId;
  final String adminId;
  final String tourId;
  final DateTime timestamp;
  final String tourImg;

  const NotificationDetailScreen({
    Key? key,
    required this.userId,
    required this.adminId,
    required this.tourId,
    required this.timestamp,
    required this.tourImg,
  }) : super(key: key);

  Future<String> _fetchUsername(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = userDoc.data();
    return data != null && data.containsKey('username') ? data['username'] : 'Unknown User';
  }

  Future<String> _fetchTourName(String tourId) async {
    final tourDoc = await FirebaseFirestore.instance.collection('tours').doc(tourId).get();
    final data = tourDoc.data();
    return data != null && data.containsKey('tourName') ? data['tourName'] : 'Unknown Tour';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Notification Details', style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: Future.wait([_fetchUsername(userId), _fetchTourName(tourId)]),
          builder: (context, AsyncSnapshot<List<String>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final username = snapshot.data![0];
            final tourName = snapshot.data![1];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tourImg.isNotEmpty)
                  Image.network(tourImg, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 16.0),
                Text(
                  'Username: $username',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Tour Name: $tourName',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Mua vào lúc: ${timestamp.toLocal().toString().substring(0, 16)}', // YYYY-MM-DD HH:MM
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
