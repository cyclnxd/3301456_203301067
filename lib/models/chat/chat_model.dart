import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/type_def.dart';

class ChatMessages {
  String idFrom;
  String idTo;
  Timestamp time;
  String content;
  int type;

  ChatMessages({
    required this.idFrom,
    required this.idTo,
    required this.time,
    required this.content,
    required this.type,
  });

  ChatMessages.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : idFrom = snapshot["idFrom"],
        idTo = snapshot["idTo"],
        time = snapshot["time"],
        type = snapshot["type"],
        content = snapshot["content"];

  JsonMap toJson() => {
        "idFrom": idFrom,
        "idTo": idTo,
        "time": time,
        "type": type,
        "content": content,
      };
}
