import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/components/custom_text_field.dart';
import 'package:subsocial/constants/paddings.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/providers/firebase_provider.dart';
import 'package:subsocial/utils/utils.dart';

import '../../../../components/comment_card.dart';
import '../../../../models/post/comment_model.dart';

class CommentsView extends ConsumerStatefulWidget {
  const CommentsView({Key? key, required this.post}) : super(key: key);

  final QueryDocumentSnapshot post;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsViewState();
}

class _CommentsViewState extends ConsumerState<CommentsView> {
  late final TextEditingController _comment;
  late final GlobalKey<FormState> _key;
  late final Future<QuerySnapshot>? _future;

  @override
  void initState() {
    _key = GlobalKey<FormState>();
    _comment = TextEditingController();
    _future = ref.read(firestoreServicesProvider).fetchComments(widget.post.id);
    super.initState();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = ref.watch(authServicesProvider).getCurrentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Comments',
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, index) => CommentCard(
              snap: snapshot.data!.docs[index],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  user?.photoURL ?? "ph_profile".phPath(),
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Form(
                    key: _key,
                    child: CustomTextFormField(
                      controller: _comment,
                      hintText: 'Comment as ${user?.displayName ?? "noname"}',
                      isAreaText: false,
                      inputType: TextInputType.text,
                      invalidText: 'Enter a comment',
                      obscureText: false,
                      border: false,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_key.currentState!.validate()) {
                    try {
                      ref.read(firestoreServicesProvider).addComment(
                            Comment(
                              content: _comment.text,
                              datePublished: Timestamp.now(),
                              profilePic: user!.photoURL!,
                              username: user.displayName!,
                              toUser: widget.post["uid"],
                            ),
                            widget.post.id,
                          );
                      _comment.clear();
                      setState(() {});
                    } catch (e) {
                      showSnackBar(context, "Could not add comment.");
                    }
                  }
                },
                child: Container(
                  padding: ProjectPaddings.gSmallPadding,
                  child: const Icon(CupertinoIcons.share),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
