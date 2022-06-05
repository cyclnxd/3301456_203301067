import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subsocial/models/post/comment_model.dart';
import 'package:subsocial/models/post/likes_model.dart';
import 'package:subsocial/models/post/post_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/user/user_model.dart';

typedef JsonMap = Map<String, dynamic>;

abstract class IFireStoreService {
  Future<void> addUser(UserModel user);
  Future<void> addPost(Post post);
  Future<void> deletePost(String postId);
  Future<void> followUser(String uid, String followId);
  Future<QuerySnapshot>? fetchUserWithId(String uid);
  Future<QuerySnapshot>? fetchUserWithUsername(String username);
  Future<QuerySnapshot>? fetchPosts();
  Future<QuerySnapshot>? fetchPostWithId(String uid);
  Future<QuerySnapshot>? fetchSaveds(String uid);
  Future<QuerySnapshot>? fetchComments(String postId);
  Future<QuerySnapshot>? fetchLikes(String postId);
  Future<QuerySnapshot<JsonMap>>? fetchActivities(String uid);
}

class FirestoreService implements IFireStoreService {
  final FirebaseFirestore _firebaseFirestore;
  FirestoreService(this._firebaseFirestore);

  @override
  Future<void> deletePost(String postId) async {
    await _firebaseFirestore.collection("posts").doc(postId).delete();
  }

  Future<void> likePost(DocumentReference postRef, Like like) async {
    final liked = await _firebaseFirestore
        .collection("posts")
        .doc(postRef.id)
        .collection("likes")
        .doc(like.uid)
        .withConverter<Like>(
          fromFirestore: (snapshot, _) =>
              Like.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (like, _) => like.toJson(),
        )
        .get();
    if (!liked.exists) {
      _firebaseFirestore
          .collection('posts')
          .doc(postRef.id)
          .collection("likes")
          .doc(like.uid)
          .withConverter<Like>(
            fromFirestore: (snapshot, _) =>
                Like.fromFirestore(snapshot: snapshot.data()!),
            toFirestore: (like, _) => like.toJson(),
          )
          .set(like);
      if (like.uid != like.toUser) {
        _firebaseFirestore
            .collection('users')
            .doc(like.toUser)
            .collection('activities')
            .doc(like.uid)
            .set({
          "post": postRef,
          "time": Timestamp.now(),
          "type": "like",
          "whoFrom": like.uid,
        });
      }
    } else {
      _firebaseFirestore
          .collection('posts')
          .doc(postRef.id)
          .collection("likes")
          .doc(like.uid)
          .withConverter<Like>(
            fromFirestore: (snapshot, _) =>
                Like.fromFirestore(snapshot: snapshot.data()!),
            toFirestore: (like, _) => like.toJson(),
          )
          .delete();
      if (like.uid != like.toUser) {
        _firebaseFirestore
            .collection('users')
            .doc(like.toUser)
            .collection('activities')
            .doc(like.uid)
            .delete();
      }
    }
  }

  @override
  Future<void> addUser(UserModel user) async {
    await _firebaseFirestore
        .collection("users")
        .doc(user.id)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) =>
              UserModel.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        )
        .set(user);
  }

  @override
  Future<void> addPost(Post post) async {
    await _firebaseFirestore
        .collection("posts")
        .doc()
        .withConverter<Post>(
          fromFirestore: (snapshot, _) =>
              Post.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (post, _) => post.toJson(),
        )
        .set(post);
  }

  Future<void> addComment(Comment comment, DocumentReference postRef) async {
    String commentId = const Uuid().v1();
    _firebaseFirestore
        .collection('posts')
        .doc(postRef.id)
        .collection('comments')
        .doc(commentId)
        .withConverter<Comment>(
          fromFirestore: (snapshot, _) =>
              Comment.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (comment, _) => comment.toJson(),
        )
        .set(comment);
    if (comment.uid != comment.toUser) {
      _firebaseFirestore
          .collection('users')
          .doc(comment.toUser)
          .collection('activities')
          .doc()
          .set({
        "post": postRef,
        "time": Timestamp.now(),
        "type": "comment",
        "whoFrom": comment.uid,
      });
    }
  }

  @override
  Future<void> followUser(String uid, String followId) async {
    DocumentSnapshot snap =
        await _firebaseFirestore.collection('users').doc(uid).get();
    List following = (snap.data()! as dynamic)['following'];

    if (following.contains(followId)) {
      await _firebaseFirestore.collection('users').doc(followId).update({
        'followers': FieldValue.arrayRemove([uid])
      });

      await _firebaseFirestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayRemove([followId])
      });

      _firebaseFirestore
          .collection('users')
          .doc(followId)
          .collection('activities')
          .doc(uid)
          .delete();
    } else {
      await _firebaseFirestore.collection('users').doc(followId).update({
        'followers': FieldValue.arrayUnion([uid])
      });

      await _firebaseFirestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayUnion([followId])
      });

      _firebaseFirestore
          .collection('users')
          .doc(followId)
          .collection('activities')
          .doc(uid)
          .set({
        "time": Timestamp.now(),
        "type": "follow",
        "whoFrom": uid,
      });
    }
  }

  @override
  Future<QuerySnapshot> fetchUserWithId(String uid) async {
    return await _firebaseFirestore
        .collection("users")
        .where("id", isEqualTo: uid)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) =>
              UserModel.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot>? fetchUserWithUsername(String username) async {
    return await _firebaseFirestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .where('username', isLessThanOrEqualTo: username + '\uf8ff')
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) =>
              UserModel.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (user, _) => user.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot>? fetchPosts() async {
    return await _firebaseFirestore
        .collection("posts")
        .orderBy("datePublished", descending: true)
        .withConverter<Post>(
          fromFirestore: (snapshot, _) =>
              Post.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (post, _) => post.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot>? fetchPostWithId(String uid) async {
    return await _firebaseFirestore
        .collection("posts")
        .where('uid', isEqualTo: uid)
        .withConverter<Post>(
          fromFirestore: (snapshot, _) =>
              Post.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (post, _) => post.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot>? fetchComments(String postId) async {
    return await _firebaseFirestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy("datePublished", descending: true)
        .withConverter<Comment>(
          fromFirestore: (snapshot, _) =>
              Comment.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (comment, _) => comment.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot>? fetchLikes(String postId) async {
    return await _firebaseFirestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .withConverter<Comment>(
          fromFirestore: (snapshot, _) =>
              Comment.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (comment, _) => comment.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot<JsonMap>> fetchActivities(String uid) async {
    return await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('activities')
        .get();
  }

  @override
  Future<QuerySnapshot>? fetchSaveds(String uid) async {
    final _saveds = await _firebaseFirestore
        .collectionGroup('saveds')
        .orderBy("datePublished", descending: true)
        .get();
    return _saveds;
  }
}
