import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/type_def.dart';

class Conversation {
  Timestamp time;
  String user;

  Conversation({
    required this.time,
    required this.user,
  });

  Conversation.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : time = snapshot["time"],
        user = snapshot["user"];

  JsonMap toJson() => {
        "time": time,
        "user": user,
      };
}
