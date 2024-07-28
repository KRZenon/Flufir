import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingWidget extends StatefulWidget {
  final String tourId;

  const RatingWidget({Key? key, required this.tourId}) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  double _rating = 0.0;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchRating();
  }

  Future<void> _fetchRating() async {
    final tourData = await FirebaseFirestore.instance.collection('tours').doc(widget.tourId).get();
    if (tourData.exists) {
      List<dynamic> ratings = tourData.data()?['ratings'] ?? [];
      if (ratings.isNotEmpty) {
        double totalRating = 0.0;
        for (var rating in ratings) {
          totalRating += rating['rating'];
        }
        setState(() {
          _rating = totalRating / ratings.length;
        });
      }
    }
  }

  void _updateRating(double rating) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Rating"),
          content: Text("Are you sure you want to give a rating of $rating?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _rating = rating;
                });
                _saveRatingToFirestore(rating);
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveRatingToFirestore(double rating) async {
    try {
      final tourRef = FirebaseFirestore.instance.collection('tours').doc(widget.tourId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final tourSnapshot = await transaction.get(tourRef);
        if (!tourSnapshot.exists) {
          throw Exception("Tour does not exist!");
        }

        List<dynamic> ratings = tourSnapshot.data()?['ratings'] ?? [];

        // Check if the user has already rated
        bool hasRated = false;
        for (var i = 0; i < ratings.length; i++) {
          if (ratings[i]['userId'] == user?.uid) {
            ratings[i]['rating'] = rating;
            hasRated = true;
            break;
          }
        }

        if (!hasRated) {
          ratings.add({
            'userId': user?.uid,
            'rating': rating,
          });
        }

        double totalRating = 0.0;
        for (var rating in ratings) {
          totalRating += rating['rating'];
        }
        double averageRating = totalRating / ratings.length;

        transaction.update(tourRef, {
          'ratings': ratings,
          'averageRating': averageRating,
        });
      });
      Get.snackbar("Success", "Your rating has been submitted.");
      print('Rating updated successfully');
    } catch (error) {
      Get.snackbar("Error", "Failed to submit rating: $error");
      print('Failed to update rating: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            _updateRating(rating);
          },
        ),
        const SizedBox(width: 8.0),
        Text(
          '$_rating/5.0',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
