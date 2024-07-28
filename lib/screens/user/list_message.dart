import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/controllers/chat_controller.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());

  ChatListScreen({super.key});

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatController.getChatListStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatList.length,
            itemBuilder: (context, index) {
              final chat = chatList[index];
              final participants = List<String>.from(chat['participants']);
              participants.remove(user!.uid); // Remove the current user ID from participants list
              final recipientId = participants.isNotEmpty ? participants.first : 'Unknown';

              return FutureBuilder<Map<String, dynamic>?>(
                future: getUserInfo(recipientId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person),
                      ),
                    );
                  }

                  final recipientData = userSnapshot.data!;
                  final recipientName = recipientData['username'] ?? 'Unknown';
                  final recipientAvatar = recipientData['userImg'] ?? '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: recipientAvatar.isNotEmpty
                          ? NetworkImage(recipientAvatar)
                          : const AssetImage('assets/default_avatar.png') as ImageProvider,
                    ),
                    title: Text(recipientName),
                    onTap: () {
                      Get.to(() => ChatScreen(recipientId: recipientId, chatId: chat.id));
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
