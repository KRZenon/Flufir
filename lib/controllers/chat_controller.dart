import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Stream<QuerySnapshot> getChatListStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return _firestore.collection('chats').where('participants', arrayContains: user.uid).snapshots();
    } else {
      throw Exception('User is not logged in');
    }
  }

  Future<String> createChat(String recipientId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    QuerySnapshot querySnapshot = await _firestore.collection('chats')
        .where('participants', arrayContains: user.uid)
        .get();

    for (var doc in querySnapshot.docs) {
      List<dynamic> participants = doc['participants'];
      if (participants.contains(recipientId)) {
        return doc.id;
      }
    }

    DocumentReference docRef = await _firestore.collection('chats').add({
      'participants': [user.uid, recipientId],
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
    return docRef.id;
  }

  Future<void> sendMessage(String chatId, String message) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': user.uid,
      'messageContent': message,
      'timestamp': Timestamp.now(),
      'messageType': 'text',
    });

    await _firestore.collection('chats').doc(chatId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> sendImage(String chatId, XFile image) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    String fileName = image.name;
    Reference storageReference = FirebaseStorage.instance.ref().child('chat_images/$chatId/$fileName');
    UploadTask uploadTask = storageReference.putFile(File(image.path));
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': user.uid,
      'messageContent': imageUrl,
      'timestamp': Timestamp.now(),
      'messageType': 'image',
    });

    await _firestore.collection('chats').doc(chatId).update({
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> pickAndSendImage(String chatId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await sendImage(chatId, image);
    }
  }
}
