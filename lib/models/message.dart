import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String recipientId;
  final String messageContent;
  final String messageType; // 'text', 'image', 'file', 'video'
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.recipientId,
    required this.messageContent,
    required this.messageType,
    required this.timestamp,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Message(
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'] ?? '',
      messageContent: data['messageContent'] ?? '',
      messageType: data['messageType'] ?? 'text',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'messageContent': messageContent,
      'messageType': messageType,
      'timestamp': timestamp,
    };
  }
}
