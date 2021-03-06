import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/type_def.dart';

class Like {
  final String? uid;
  final String profilePic;
  final String username;
  final String toUser;
  final Timestamp datePublished;

  Like({
    this.uid,
    required this.profilePic,
    required this.username,
    required this.datePublished,
    required this.toUser,
  });

  Like.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : uid = snapshot["uid"],
        profilePic = snapshot["profilePic"],
        username = snapshot["username"],
        datePublished = snapshot["datePublished"],
        toUser = snapshot["toUser"];

  JsonMap toJson() => {
        "uid": uid,
        "profilePic": profilePic,
        "username": username,
        "datePublished": datePublished,
        "toUser": toUser,
      };
}
