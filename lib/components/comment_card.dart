import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:subsocial/constants/paddings.dart';

import '../utils/utils.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({Key? key, required this.snap}) : super(key: key);
  final QueryDocumentSnapshot snap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ProjectPaddings.gMediumPadding,
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              snap['profilePic'],
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
                        snap['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' ${snap['content']}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      datePicker(
                          start: snap['datePublished'].toDate(),
                          end: DateTime.now()),
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
