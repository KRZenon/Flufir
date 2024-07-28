import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getCustomerDeviceToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  } catch (e) {
    print("Error: $e");
    throw Exception("Error getting device token");
  }
}
