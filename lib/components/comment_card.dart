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
      padding: ProjectPaddings.vSmallPadding,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            _comment.profilePic,
          ),
          radius: 18,
        ),
        title: Row(
          children: [
            Text(
              _comment.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        horizontalTitleGap: 5.0,
        subtitle: Text(
          ' ${_comment.content}',
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border_rounded),
        ),
      ),
    );
  }
}


// Container(
//   color: Color.fromRGBO(224, 251, 253, 1.0),
//   child: ListTile(
//     dense: true,
//     title: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         RichText(
//           textAlign: TextAlign.left,
//           softWrap: true,
//           text: TextSpan(children: <TextSpan>
//           [
//             TextSpan(text: "hello: ",
//                 style: TextStyle(
//                     color: Colors.black, fontWeight: FontWeight.bold)),
//             TextSpan(text: "I hope this helps",
//                 style: TextStyle(color: Colors.black)),
//           ]
//           ),
//         ),
//       ],
//     ),
//   ),
// ),


// Row(
//         children: [
//           CircleAvatar(
//             backgroundImage: NetworkImage(
//               _comment.profilePic,
//             ),
//             radius: 18,
//           ),

//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         _comment.username,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Flexible(
//                         child: Text(
//                           ' ${_comment.content}',
//                           overflow: TextOverflow.clip,
//                         ),
//                       )
//                     ],
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text(
//                       datePicker(
//                         start: _comment.datePublished.toDate(),
//                         end: DateTime.now(),
//                       ),
//                       style: Theme.of(context).textTheme.labelMedium,
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),