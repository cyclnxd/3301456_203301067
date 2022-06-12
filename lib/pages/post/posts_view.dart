import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:subsocial/components/post_card.dart';

class PostsView extends ConsumerStatefulWidget {
  const PostsView(
      {Key? key, required this.posts, required this.title, required this.index})
      : super(key: key);

  final List<QueryDocumentSnapshot> posts;
  final String title;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PostsViewState();
}

class _PostsViewState extends ConsumerState<PostsView> {
  final ItemScrollController _scrollController = ItemScrollController();

  void _scrollToIndex(int index) {
    _scrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.isAttached) {
        _scrollToIndex(widget.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List posts = widget.posts;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(widget.title),
      ),
      body: ScrollablePositionedList.builder(
        itemCount: posts.length,
        itemBuilder: (_, index) => PostCard(
          post: posts[index],
          index: index,
        ),
        itemScrollController: _scrollController,
      ),
    );
  }
}
