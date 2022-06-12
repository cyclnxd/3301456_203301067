import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/type_def.dart';

class Activities {
  final String? uid;
  final String whoFrom;
  final DocumentReference? post;
  final String type;
  final Timestamp time;

  Activities({
    this.uid,
    this.post,
    required this.whoFrom,
    required this.type,
    required this.time,
  });

  Activities.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : uid = snapshot["uid"],
        time = snapshot["time"],
        post = snapshot["post"],
        whoFrom = snapshot["whoFrom"],
        type = snapshot["type"];

  JsonMap toJson() => {
        "uid": uid,
        "type": type,
        "post": post,
        "time": time,
        "whoFrom": whoFrom,
      };
}
