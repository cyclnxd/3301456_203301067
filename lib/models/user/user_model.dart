import 'package:cloud_firestore/cloud_firestore.dart';

typedef JsonMap = Map<String, dynamic>;

class UserModel {
  final String id;
  final String username;
  final String name;
  final String surname;
  final String profImage;
  final String bio;
  final List followers;
  final List following;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.surname,
    required this.profImage,
    required this.bio,
    required this.followers,
    required this.following,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? name,
    String? surname,
    String? profImage,
    String? bio,
    List? followers,
    List? following,
  }) =>
      UserModel(
        id: id ?? this.id,
        username: username ?? this.username,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        profImage: profImage ?? this.profImage,
        bio: bio ?? this.bio,
        followers: followers ?? this.followers,
        following: following ?? this.following,
      );

  UserModel.fromFirestore({
    required JsonMap snapshot,
    SnapshotOptions? options,
  })  : id = snapshot["id"],
        username = snapshot["username"],
        name = snapshot["name"],
        surname = snapshot["surname"],
        profImage = snapshot["profImage"],
        bio = snapshot["bio"],
        followers = snapshot["followers"],
        following = snapshot["following"];

  JsonMap toJson() {
    return {
      "id": id,
      "username": username,
      "name": name,
      "surname": surname,
      "profImage": profImage,
      "bio": bio,
      "followers": followers,
      "following": following,
    };
  }
}
