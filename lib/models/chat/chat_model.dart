import 'package:cloud_firestore/cloud_firestore.dart';

typedef JsonMap = Map<String, dynamic>;

class ChatMessages {
  String idFrom;
  String idTo;
  String time;
  String content;

  ChatMessages({
    required this.idFrom,
    required this.idTo,
    required this.time,
    required this.content,
  });

  ChatMessages.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : idFrom = snapshot["idFrom"],
        idTo = snapshot["idTo"],
        time = snapshot["time"],
        content = snapshot["content"];

  JsonMap toJson() => {
        "idFrom": idFrom,
        "idTo": idTo,
        "time": time,
        "content": content,
      };
}
