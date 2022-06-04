import 'package:cloud_firestore/cloud_firestore.dart';

typedef JsonMap = Map<String, dynamic>;

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final int likes;
  final Timestamp datePublished;
  final String postUrl;
  final String profImage;
  final String location;

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.likes,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.location,
  });

  Post.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : description = snapshot["description"],
        uid = snapshot["uid"],
        postId = snapshot["postId"],
        datePublished = snapshot["datePublished"],
        username = snapshot["username"],
        likes = snapshot["likes"],
        postUrl = snapshot['postUrl'],
        profImage = snapshot['profImage'],
        location = snapshot['location'];

  JsonMap toJson() => {
        "description": description,
        "uid": uid,
        "username": username,
        "postId": postId,
        "likes": likes,
        "datePublished": datePublished,
        'postUrl': postUrl,
        'profImage': profImage,
        'location': location
      };
}
