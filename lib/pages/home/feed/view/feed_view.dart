import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial/components/loading.dart';
import 'package:subsocial/components/not_found_widget.dart';
import 'package:subsocial/components/post_card.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/models/post/post_model.dart';
import 'package:subsocial/providers/theme_provider.dart';
import 'package:subsocial/services/navigation/navigation_service.dart';

import '../../../../providers/firebase_provider.dart';

class FeedView extends ConsumerStatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView> {
  late final Future<QuerySnapshot<Post>>? _future;
  late final ScrollController _scrollController;
  late final User? _currentUser;
  final List _following = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    _currentUser = ref.watch(authServicesProvider).getCurrentUser;
    ref
        .watch(firestoreServicesProvider)
        .fetchUserWithId(_currentUser!.uid)
        .then(
      (value) {
        _following.addAll((value.docs.first.data()).following);
        _following.remove(0);
      },
    );
    _future = ref.watch(firestoreServicesProvider).fetchPosts();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: GestureDetector(
          onTap: () async {
            await _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 800),
              curve: Curves.fastOutSlowIn,
            );
            setState(() {});
          },
          child: ref.watch(themeDataProvider)
              ? SvgPicture.asset(
                  "ic_s_outlined_white.svg".svgPath(),
                  height: 40,
                  width: 80,
                )
              : SvgPicture.asset(
                  "ic_s_outlined_black.svg".svgPath(),
                  height: 40,
                  width: 80,
                ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              NavigationService.instance.navigateToPage(path: '/chat-list');
            },
            icon: const Icon(CupertinoIcons.chat_bubble_2),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<QuerySnapshot<Post>>(
          future: _future,
          builder: (_, snap) {
            if (snap.hasData) {
              return ListView.builder(
                itemCount: snap.data!.docs.length,
                controller: _scrollController,
                itemBuilder: (_, index) {
                  var _post = snap.data!.docs[index].data();

                  return _following.contains(_post.uid) ||
                          _post.uid == _currentUser!.uid
                      ? PostCard(
                          post: snap.data!.docs[index],
                          index: index,
                        )
                      : const SizedBox.shrink();
                },
              );
            } else if (snap.connectionState == ConnectionState.waiting) {
              return const Loading();
            } else {
              return const NotFoundNavigationWidget();
            }
          },
        ),
      ),
    );
  }
}
