import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/type_def.dart';

class Saveds {
  final String? uid;
  final DocumentReference post;
  final Timestamp datePublished;

  Saveds({
    this.uid,
    required this.datePublished,
    required this.post,
  });

  Saveds.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : uid = snapshot["uid"],
        datePublished = snapshot["datePublished"],
        post = snapshot["post"];

  JsonMap toJson() => {
        "datePublished": datePublished,
        "post": post,
      };
}
