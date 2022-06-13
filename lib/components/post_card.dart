import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/models/post/post_model.dart';
import 'package:subsocial/providers/firebase_provider.dart';
import 'package:subsocial/services/navigation/navigation_service.dart';

import '../constants/paddings.dart';
import '../models/post/likes_model.dart';
import '../models/post/saveds_model.dart';
import 'like_animation.dart';

class PostCard extends ConsumerStatefulWidget {
  const PostCard({Key? key, required this.post, required this.index})
      : super(key: key);

  final QueryDocumentSnapshot<Post> post;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  final _iconSize = 30.0;
  final Color _randomColor =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];
  late Post _post;

  bool isLikeAnimating = false;
  bool _isSaved = false;
  bool liked = false;

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    if (oldWidget.post.data() != widget.post.data()) {
      setState(() {
        _post = widget.post.data();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _post = widget.post.data();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _user = ref.watch(authServicesProvider).getCurrentUser;

    void postLike(String uid) async {
      await ref.read(firestoreServicesProvider).likePost(
            widget.post.reference,
            Like(
              uid: _user!.uid,
              username: _user.displayName!,
              datePublished: Timestamp.now(),
              profilePic: _user.photoURL!,
              toUser: uid,
            ),
          );
    }

    return FutureBuilder<QuerySnapshot<Like>>(
      future: ref
          .watch(firestoreServicesProvider)
          .fetchLikes(widget.post.reference.id),
      builder: (_, AsyncSnapshot<QuerySnapshot<Like>> snap) {
        if (!snap.hasData) {
          return Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: Lottie.asset(
                  height: MediaQuery.of(context).size.height * 0.5,
                  "ic_indicator.json".lottiePath(),
                ),
              ),
            ),
          );
        } else {
          Iterable<String?> _likes = [];
          _likes = snap.data!.docs.map((e) => e.data().uid);
          liked = _likes.contains(_user!.uid);
          return Padding(
            padding: MediaQuery.of(context).size.width > 600
                ? EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.3) +
                    const EdgeInsets.only(bottom: 15)
                : const EdgeInsets.only(bottom: 15),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    NavigationService.instance.navigateToPage(
                      path: "/profile",
                      data: _post.uid,
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          _post.profImage,
                        ),
                      ),
                    ),
                    title: Text(
                      _post.username,
                    ),
                  ),
                ),
                _post.location.isNotEmpty
                    ? Padding(
                        padding: ProjectPaddings.gSmallPadding +
                            ProjectPaddings.hSmallPadding * 2.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              _post.location,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                GestureDetector(
                  onDoubleTap: () async {
                    setState(() {
                      isLikeAnimating = true;
                    });
                    if (!liked) {
                      postLike(_post.uid);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.height * 0.5,
                          fit: BoxFit.fill,
                          imageUrl: _post.postUrl,
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
                          errorWidget: (_, __, ___) => const Icon(Icons.error),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isLikeAnimating ? 1 : 0,
                        child: LikeAnimation(
                          isAnimating: isLikeAnimating,
                          child: Icon(
                            CupertinoIcons.suit_spade_fill,
                            color: _randomColor,
                            size: 100,
                          ),
                          duration: const Duration(
                            milliseconds: 400,
                          ),
                          onEnd: () {
                            setState(() {
                              isLikeAnimating = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      iconSize: _iconSize,
                      onPressed: () async {
                        setState(() {
                          liked = !liked;
                        });
                        postLike(_post.uid);
                      },
                      color: _randomColor,
                      icon: liked
                          ? const Icon(CupertinoIcons.suit_spade_fill)
                          : const Icon(CupertinoIcons.suit_spade),
                    ),
                    IconButton(
                      iconSize: _iconSize,
                      onPressed: () {
                        NavigationService.instance.navigateToPage(
                          path: '/comments',
                          data: widget.post,
                        );
                      },
                      icon: const Icon(CupertinoIcons.ellipses_bubble),
                    ),
                    IconButton(
                      iconSize: _iconSize,
                      onPressed: () {},
                      icon: const Icon(Icons.send_outlined),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: FutureBuilder<QuerySnapshot<Saveds>>(
                          future: ref
                              .watch(firestoreServicesProvider)
                              .fetchSaveds(_user.uid),
                          builder: (
                            _,
                            AsyncSnapshot<QuerySnapshot<Saveds>> savedsnap,
                          ) {
                            if (savedsnap.hasData) {
                              Iterable _refs = [];
                              _refs = savedsnap.data!.docs
                                  .map((e) => e.data().post.id);
                              _isSaved =
                                  _refs.contains(widget.post.reference.id);

                              return IconButton(
                                iconSize: _iconSize,
                                onPressed: () {
                                  ref.read(firestoreServicesProvider).savePost(
                                        widget.post.reference,
                                        _user.uid,
                                      );
                                  setState(() {});
                                },
                                icon: _isSaved
                                    ? const Icon(CupertinoIcons.bookmark_fill)
                                    : const Icon(CupertinoIcons.bookmark),
                              );
                            } else {
                              return IconButton(
                                iconSize: _iconSize,
                                onPressed: () {},
                                icon: const Icon(CupertinoIcons.bookmark),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: ProjectPaddings.hSmallPadding * 2.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          NavigationService.instance.navigateToPage(
                            path: '/likes',
                            data: widget.post.reference.id,
                          );
                        },
                        child: Text(
                          "${snap.data!.docs.length} liked",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: ProjectPaddings.gSmallPadding * 2.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          NavigationService.instance.navigateToPage(
                            path: '/profile',
                            data: _post.uid,
                          );
                        },
                        child: Text(
                          _post.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            NavigationService.instance.navigateToPage(
                              path: '/comments',
                              data: widget.post.reference.id,
                            );
                          },
                          child: Padding(
                            padding: ProjectPaddings.hSmallPadding,
                            child: Text(
                              _post.description,
                              style: const TextStyle(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
