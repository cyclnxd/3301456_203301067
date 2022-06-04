import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:subsocial/components/loading.dart';
import 'package:subsocial/components/not_found_widget.dart';
import 'package:subsocial/components/post_card.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/models/user/user_model.dart';
import 'package:subsocial/providers/theme_provider.dart';

import '../../../../providers/firebase_provider.dart';

class FeedView extends ConsumerStatefulWidget {
  const FeedView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<FeedView> {
  late final Future<QuerySnapshot>? _future;
  late final ScrollController _scrollController;
  final List _following = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    final _currentUser = ref.watch(authServicesProvider).getCurrentUser;
    ref
        .watch(firestoreServicesProvider)
        .fetchUserWithId(_currentUser!.uid)
        .then(
      (value) {
        _following.addAll((value.docs.first.data() as UserModel).following);
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
              ref.read(authServicesProvider).signOut();
            },
            icon: const Icon(Icons.logout_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.light_mode_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: FutureBuilder<QuerySnapshot>(
          future: _future,
          builder: (_, snap) {
            if (snap.hasData) {
              return ListView(
                controller: _scrollController,
                children: [
                  for (final post in snap.data!.docs)
                    _following.contains(post["uid"])
                        ? PostCard(post: post)
                        : const SizedBox.shrink()
                ],
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
