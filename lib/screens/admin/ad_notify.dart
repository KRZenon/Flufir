import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/utils/constant.dart';

import '../../controllers/ad_notify_controller.dart';
import 'ad_notification_detail.dart'; // Import lại nếu cần thiết

class NotificationScreen extends StatelessWidget {
  final NotificationController notificationController = Get.find();

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstant.appMainColor,
        title: const Text('Notifications', style: TextStyle(color: AppConstant.appTextColor)),
        iconTheme: const IconThemeData(color: AppConstant.appStatusBarColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationController.getNotificationsStream(currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final data = notification.data() as Map<String, dynamic>;
              final isRead = data['read'] ?? false;

              return ListTile(
                title: Text(
                  data['message'],
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _formatTimestamp(data['timestamp']),
                ),
                leading: data['tourImg'] != null
                    ? Image.network(data['tourImg'], width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                onTap: () {
                  notificationController.markAsRead(notification.id);
                  Get.to(() => NotificationDetailScreen(
                    userId: data['userId'],
                    adminId: data['adminId'],
                    tourId: data['tourId'],
                    timestamp: (data['timestamp'] as Timestamp).toDate(),
                    tourImg: data['tourImg'],
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
