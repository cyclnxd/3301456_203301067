import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:subsocial/constants/paddings.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/models/post/post_model.dart';

import '../../../../components/loading.dart';
import '../../../../models/post/saveds_model.dart';
import '../../../../providers/firebase_provider.dart';

class SavedsView extends ConsumerStatefulWidget {
  const SavedsView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SavedsViewState();
}

class _SavedsViewState extends ConsumerState<SavedsView> {
  @override
  Widget build(BuildContext context) {
    final _user = ref.watch(authServicesProvider).getCurrentUser;
    final Future<QuerySnapshot<Saveds>>? _post =
        ref.watch(firestoreServicesProvider).fetchSaveds(_user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saveds"),
      ),
      body: FutureBuilder<QuerySnapshot<Saveds>?>(
        future: _post,
        builder: (_, AsyncSnapshot<QuerySnapshot<Saveds>?> snap) {
          if (snap.hasData) {
            return Padding(
              padding:
                  ProjectPaddings.vSmallPadding + ProjectPaddings.hSmallPadding,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: snap.data!.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 6 : 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, index) {
                  var _savedPosts = snap.data!.docs;
                  return FutureBuilder<DocumentSnapshot<Post>?>(
                    future: ref
                        .watch(firestoreServicesProvider)
                        .fetchPostWithUid(_savedPosts[index].data().post.id),
                    builder:
                        (_, AsyncSnapshot<DocumentSnapshot<Post>?> snapshot) {
                      if (snapshot.hasData) {
                        var _post = snapshot.data!.data();

                        return CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: _post?.postUrl ?? "",
                          placeholder: (_, __) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                              child: Lottie.asset(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                "ic_indicator.json".lottiePath(),
                              ),
                            ),
                          ),
                        );
                      }
                      return const Loading();
                    },
                  );
                },
              ),
            );
          } else {
            return const Loading();
          }
        },
      ),
    );
  }
}
