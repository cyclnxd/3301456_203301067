import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:subsocial/models/chat/chat_model.dart';
import 'package:subsocial/models/chat/conversation_model.dart';
import 'package:subsocial/models/post/comment_model.dart';
import 'package:subsocial/models/post/likes_model.dart';
import 'package:subsocial/models/post/post_model.dart';
import 'package:subsocial/models/post/saveds_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/activities/activities_model.dart';
import '../../../../models/user/user_model.dart';

typedef JsonMap = Map<String, dynamic>;

abstract class IFireStoreService {
  Future<void> addUser(UserModel user);
  Future<void> addPost(Post post);
  Future<void> deletePost(String postId);
  Future<void> followUser(String uid, String followId);
  Future<QuerySnapshot<UserModel>>? fetchUserWithId(String uid);
  Future<QuerySnapshot<UserModel>>? fetchUserWithUsername(String username);
  Future<QuerySnapshot<Post>>? fetchPosts();
  Future<QuerySnapshot<Post>>? fetchPostWithId(String uid);
  Future<DocumentSnapshot<Post>>? fetchPostWithUid(String uid);
  Future<QuerySnapshot<Saveds>>? fetchSaveds(String uid);
  Future<QuerySnapshot<Comment>>? fetchComments(String postId);
  Future<QuerySnapshot<Like>>? fetchLikes(String postId);
  Future<QuerySnapshot<Activities>>? fetchActivities(String uid);
  Stream<QuerySnapshot<Conversation>>? fetchConversations(String uid);
  Stream<QuerySnapshot<ChatMessages>>? fetchMessages(
    String uid,
    String conversationId,
  );
  Future<QueryDocumentSnapshot<Conversation>> createConversation(
    String senderUid,
    String receiverUid,
  );
  Future<void> sendMessage(
    String senderUid,
    String receiverUid,
    String conversationId,
    ChatMessages chatMessages,
  );
}

class FirestoreService implements IFireStoreService {
  final FirebaseFirestore _firebaseFirestore;
  FirestoreService(this._firebaseFirestore);

  @override
  Future<void> deletePost(String postId) async {
    await _firebaseFirestore.collection("posts").doc(postId).delete();
  }

  Future<void> savePost(DocumentReference postRef, String uid) async {
    final saved = await _firebaseFirestore
        .collection("users")
        .doc(uid)
        .collection("saveds")
        .where('post', isEqualTo: postRef)
        .withConverter<Like>(
          fromFirestore: (snapshot, _) =>
              Like.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (like, _) => like.toJson(),
        )
        .get();

    if (saved.docs.isEmpty) {
      _firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('saveds')
          .withConverter<Saveds>(
            fromFirestore: (snapshot, _) =>
                Saveds.fromFirestore(snapshot: snapshot.data()!),
            toFirestore: (saveds, _) => saveds.toJson(),
          )
          .add(
            Saveds(
              datePublished: Timestamp.now(),
              post: postRef,
            ),
          );
    } else {
      _firebaseFirestore
          .collection('users')
          .doc(uid)
          .collection('saveds')
          .doc(saved.docs.first.id)
          .withConverter<Saveds>(
            fromFirestore: (snapshot, _) =>
                Saveds.fromFirestore(snapshot: snapshot.data()!),
            toFirestore: (saveds, _) => saveds.toJson(),
          )
          .delete();
    }
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
  Future<QuerySnapshot<UserModel>> fetchUserWithId(String uid) async {
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
  Future<QuerySnapshot<UserModel>>? fetchUserWithUsername(
      String username) async {
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
  Future<QuerySnapshot<Post>>? fetchPosts() async {
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
  Future<QuerySnapshot<Post>>? fetchPostWithId(String uid) async {
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
  Future<DocumentSnapshot<Post>>? fetchPostWithUid(String uid) async {
    return await _firebaseFirestore
        .collection("posts")
        .doc(uid)
        .withConverter<Post>(
          fromFirestore: (snapshot, _) =>
              Post.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (post, _) => post.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot<Comment>>? fetchComments(String postId) async {
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
  Future<QuerySnapshot<Like>>? fetchLikes(String postId) async {
    return await _firebaseFirestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .withConverter<Like>(
          fromFirestore: (snapshot, _) =>
              Like.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (like, _) => like.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot<Activities>> fetchActivities(String uid) async {
    return await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('activities')
        .withConverter<Activities>(
          fromFirestore: (snapshot, _) =>
              Activities.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (activities, _) => activities.toJson(),
        )
        .get();
  }

  @override
  Future<QuerySnapshot<Saveds>>? fetchSaveds(String uid) async {
    return await _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('saveds')
        .withConverter<Saveds>(
          fromFirestore: (snapshot, _) =>
              Saveds.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (saveds, _) => saveds.toJson(),
        )
        .get();
  }

  @override
  Future<QueryDocumentSnapshot<Conversation>> createConversation(
    String senderUid,
    String receiverUid,
  ) async {
    return _firebaseFirestore
        .collection('users')
        .doc(senderUid)
        .collection('conversations')
        .where('user', isEqualTo: receiverUid)
        .withConverter<Conversation>(
          fromFirestore: (snapshot, _) =>
              Conversation.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (conversation, _) => conversation.toJson(),
        )
        .get()
        .then(
      (value) async {
        if (value.docs.isNotEmpty) {
          return value.docs.first;
        } else {
          String uuid = const Uuid().v1();
          await _firebaseFirestore
              .collection('users')
              .doc(receiverUid)
              .collection('conversations')
              .doc(uuid)
              .withConverter<Conversation>(
                fromFirestore: (snapshot, _) =>
                    Conversation.fromFirestore(snapshot: snapshot.data()!),
                toFirestore: (conversation, _) => conversation.toJson(),
              )
              .set(
                Conversation(
                  time: Timestamp.now(),
                  user: senderUid,
                ),
              );

          await _firebaseFirestore
              .collection('users')
              .doc(senderUid)
              .collection('conversations')
              .doc(uuid)
              .withConverter<Conversation>(
                fromFirestore: (snapshot, _) =>
                    Conversation.fromFirestore(snapshot: snapshot.data()!),
                toFirestore: (conversation, _) => conversation.toJson(),
              )
              .set(
                Conversation(
                  time: Timestamp.now(),
                  user: receiverUid,
                ),
              );
          return _firebaseFirestore
              .collection('users')
              .doc(senderUid)
              .collection('conversations')
              .where('user', isEqualTo: receiverUid)
              .withConverter<Conversation>(
                fromFirestore: (snapshot, _) =>
                    Conversation.fromFirestore(snapshot: snapshot.data()!),
                toFirestore: (conversation, _) => conversation.toJson(),
              )
              .get()
              .then((value) => value.docs.first);
        }
      },
    );
  }

  @override
  Stream<QuerySnapshot<Conversation>>? fetchConversations(String uid) {
    return _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .withConverter<Conversation>(
          fromFirestore: (snapshot, _) =>
              Conversation.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (conversation, _) => conversation.toJson(),
        )
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<ChatMessages>>? fetchMessages(
    String uid,
    String conversationId,
  ) {
    return _firebaseFirestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('time', descending: true)
        .withConverter<ChatMessages>(
          fromFirestore: (snapshot, _) =>
              ChatMessages.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (message, _) => message.toJson(),
        )
        .snapshots();
  }

  @override
  Future<void> sendMessage(
    String senderUid,
    String receiverUid,
    String conversationId,
    ChatMessages chatMessages,
  ) async {
    await _firebaseFirestore
        .collection('users')
        .doc(receiverUid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .withConverter<ChatMessages>(
          fromFirestore: (snapshot, _) =>
              ChatMessages.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (message, _) => message.toJson(),
        )
        .add(chatMessages);
    await _firebaseFirestore
        .collection('users')
        .doc(senderUid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .withConverter<ChatMessages>(
          fromFirestore: (snapshot, _) =>
              ChatMessages.fromFirestore(snapshot: snapshot.data()!),
          toFirestore: (message, _) => message.toJson(),
        )
        .add(chatMessages);
  }
}
