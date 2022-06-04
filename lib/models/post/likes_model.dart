import 'package:cloud_firestore/cloud_firestore.dart';

typedef JsonMap = Map<String, dynamic>;

class Like {
  final String? uid;
  final String profilePic;
  final String username;
  final Timestamp datePublished;

  Like({
    this.uid,
    required this.profilePic,
    required this.username,
    required this.datePublished,
  });

  Like.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : uid = snapshot["uid"],
        profilePic = snapshot["profilePic"],
        username = snapshot["username"],
        datePublished = snapshot["datePublished"];

  JsonMap toJson() => {
        "uid": uid,
        "profilePic": profilePic,
        "username": username,
        "datePublished": datePublished,
      };
}
