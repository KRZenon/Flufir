import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flufir/controllers/chat_controller.dart';
import 'user_profile_screen.dart'; // Import UserProfileScreen

class ChatScreen extends StatelessWidget {
  final String recipientId;
  final String chatId;
  final ChatController chatController = Get.put(ChatController());

  ChatScreen({required this.recipientId, required this.chatId, super.key});

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
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == user!.uid;
                    final messageType = message['messageType'];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: getUserInfo(isMe ? user.uid : recipientId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        }

                        final userData = userSnapshot.data!;
                        final userAvatar = userData['userImg'] ?? '';
                        final userInitial = userData['username']?.substring(0, 1).toUpperCase() ?? '';

                        return ListTile(
                          leading: isMe
                              ? null
                              : GestureDetector(
                            onTap: () {
                              Get.to(() => UserProfileScreen(user: FirebaseAuth.instance.currentUser),
                                  arguments: {
                                    'userId': recipientId,
                                    'isEditable': false,
                                  }); // Chuyển tới UserProfileScreen với userId và isEditable là false
                            },
                            child: CircleAvatar(
                              backgroundImage: userAvatar.isNotEmpty
                                  ? NetworkImage(userAvatar)
                                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
                              child: userAvatar.isEmpty ? Text(userInitial) : null,
                            ),
                          ),
                          trailing: isMe
                              ? GestureDetector(
                            onTap: () {
                              Get.to(() => UserProfileScreen(user: FirebaseAuth.instance.currentUser),
                                  arguments: {
                                    'userId': user.uid,
                                    'isEditable': true,
                                  }); // Chuyển tới UserProfileScreen với userId và isEditable là true
                            },
                            child: CircleAvatar(
                              backgroundImage: userAvatar.isNotEmpty
                                  ? NetworkImage(userAvatar)
                                  : const AssetImage('assets/default_avatar.png') as ImageProvider,
                              child: userAvatar.isEmpty ? Text(userInitial) : null,
                            ),
                          )
                              : null,
                          title: Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: messageType == 'image'
                                ? Image.network(message['messageContent'])
                                : Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(message['messageContent']),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {
                    chatController.pickAndSendImage(chatId);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: chatController.messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    chatController.sendMessage(chatId, chatController.messageController.text);
                    chatController.messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
