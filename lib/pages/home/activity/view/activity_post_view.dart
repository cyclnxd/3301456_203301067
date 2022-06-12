import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial/components/activity_post_card.dart';

import '../../../../models/post/post_model.dart';

class ActivityPostView extends ConsumerStatefulWidget {
  const ActivityPostView({Key? key, required this.post}) : super(key: key);

  final DocumentSnapshot<Post> post;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ActivityPostViewState();
}

class _ActivityPostViewState extends ConsumerState<ActivityPostView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Activities"),
      ),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (_, index) => ActivityPostCard(
          post: widget.post,
          index: index,
        ),
      ),
    );
  }
}
