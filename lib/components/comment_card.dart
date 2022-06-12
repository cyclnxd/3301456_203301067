import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:subsocial/constants/paddings.dart';
import 'package:subsocial/models/post/comment_model.dart';

import '../utils/utils.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({Key? key, required this.snap}) : super(key: key);
  final QueryDocumentSnapshot<Comment> snap;

  @override
  Widget build(BuildContext context) {
    Comment _comment = snap.data();
    return Container(
      padding: ProjectPaddings.gMediumPadding,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              _comment.profilePic,
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        _comment.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' ${_comment.content}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      datePicker(
                        start: _comment.datePublished.toDate(),
                        end: DateTime.now(),
                      ),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
