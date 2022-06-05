import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/navigation/navigation_service.dart';

class ActivityCard extends ConsumerStatefulWidget {
  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  final activity;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityCardState();
}

class _ActivityCardState extends ConsumerState<ActivityCard> {
  String _activityText = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
          (widget.activity["post"] as DocumentReference).get().then((value) {
        return value;
      }),
      builder: (_, AsyncSnapshot snapshot) {
        switch (widget.activity["type"]) {
          case "like":
            _activityText = "Liked your photo";
            break;
          case "comment":
            _activityText = "Comment your photo";
            break;
          case "follow":
            _activityText = "Follow you";
            break;
          default:
            _activityText = "";
            break;
        }
        if (snapshot.hasData) {
          var _post = snapshot.data.data();

          return ListTile(
            leading: GestureDetector(
              onTap: () {
                NavigationService.instance.navigateToPage(
                  path: "/profile",
                  data: _post["uid"],
                );
              },
              child: CircleAvatar(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    _post["profImage"],
                  ),
                ),
              ),
            ),
            trailing: GestureDetector(
              onTap: () {
                NavigationService.instance
                    .navigateToPage(path: '/post-view', data: snapshot.data);
              },
              child: Image.network(
                _post["postUrl"],
              ),
            ),
            title: Text(_post["username"]),
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
