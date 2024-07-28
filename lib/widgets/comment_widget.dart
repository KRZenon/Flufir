import 'package:flufir/screens/user/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentWidget extends StatefulWidget {
  final String tourId;

  const CommentWidget({Key? key, required this.tourId}) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _addComment(String comment) async {
    try {
      final commentRef = FirebaseFirestore.instance.collection('comments').doc(widget.tourId).collection('tourComments').doc();
      await commentRef.set({
        'comment': comment,
        'userId': user?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
      Get.snackbar("Success", "Your comment has been submitted.");
      print('Comment added successfully');
    } catch (error) {
      Get.snackbar("Error", "Failed to submit comment: $error");
      print('Failed to add comment: $error');
    }
  }

  Future<Map<String, dynamic>> _getUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!;
      } else {
        return {'username': 'Unknown User', 'userImg': ''};
      }
    } catch (e) {
      return {'username': 'Unknown User', 'userImg': ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comments",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('comments')
              .doc(widget.tourId)
              .collection('tourComments')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final comments = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final commentData = comments[index];
                final comment = commentData['comment'];
                final userId = commentData['userId'];
                return FutureBuilder<Map<String, dynamic>>(
                  future: _getUserData(userId),
                  builder: (context, userDataSnapshot) {
                    if (!userDataSnapshot.hasData) {
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    }
                    final userData = userDataSnapshot.data!;
                    final userName = userData['username'];
                    final userImg = userData['userImg'];
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
                          backgroundImage: userImg.isNotEmpty
                              ? NetworkImage(userImg)
                              : const AssetImage('assets/default_avatar.png') as ImageProvider,
                          child: userImg.isEmpty ? Text(userName.substring(0, 1).toUpperCase()) : null,
                        ),
                      ),
                      title: Text(comment),
                      subtitle: Text('User: $userName'),
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 16.0),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: "Enter your comment",
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  _addComment(_commentController.text);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
