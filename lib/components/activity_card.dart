import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/models/activities/activities_model.dart';
import 'package:subsocial/models/post/post_model.dart';
import 'package:subsocial/providers/firebase_provider.dart';

import '../models/user/user_model.dart';
import '../services/navigation/navigation_service.dart';

class ActivityCard extends ConsumerStatefulWidget {
  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  final QueryDocumentSnapshot<Activities> activity;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityCardState();
}

class _ActivityCardState extends ConsumerState<ActivityCard> {
  String _activityText = '';

  late Activities _activities;

  @override
  void didUpdateWidget(covariant ActivityCard oldWidget) {
    if (oldWidget.activity.data() != widget.activity.data()) {
      setState(() {
        _activities = widget.activity.data();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _activities = widget.activity.data();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (_activities.type) {
      case "like":
        _activityText = "Liked your photo";
        break;
      case "comment":
        _activityText = "Comment your photo";
        break;
      case "follow":
        _activityText = "Followed you";
        break;
      default:
        _activityText = "";
        break;
    }
    if (_activities.post != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: (_activities.post)
            ?.withConverter(
                fromFirestore: (snapshot, options) =>
                    Post.fromFirestore(snapshot: snapshot.data()!),
                toFirestore: (_, __) => {})
            .get()
            .then((value) {
          return value;
        }),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            Post? _post = snapshot.data?.data() as Post;
            return FutureBuilder<QuerySnapshot<UserModel>>(
              future: ref
                  .watch(firestoreServicesProvider)
                  .fetchUserWithId(_activities.whoFrom),
              builder: (_, userSnap) {
                if (userSnap.hasData) {
                  UserModel _user = userSnap.data!.docs.first.data();
                  return ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        NavigationService.instance.navigateToPage(
                          path: "/profile",
                          data: _post.uid,
                        );
                      },
                      child: CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            _user.profImage,
                          ),
                        ),
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        NavigationService.instance.navigateToPage(
                          path: '/activity-post',
                          data: snapshot.data,
                        );
                      },
                      child: Image.network(
                        _post.postUrl,
                      ),
                    ),
                    title: Text(_user.username),
                    subtitle: Text(
                      _activityText,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    } else {
      return FutureBuilder<QuerySnapshot<UserModel>>(
        future: ref
            .watch(firestoreServicesProvider)
            .fetchUserWithId(_activities.whoFrom),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            UserModel _user = snapshot.data?.docs.first.data() as UserModel;
            return ListTile(
              leading: GestureDetector(
                onTap: () {
                  NavigationService.instance.navigateToPage(
                    path: "/profile",
                    data: _user.id,
                  );
                },
                child: CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      _user.profImage,
                    ),
                  ),
                ),
              ),
              title: Text(_user.username),
              subtitle: Text(
                _activityText,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    }
  }
}
