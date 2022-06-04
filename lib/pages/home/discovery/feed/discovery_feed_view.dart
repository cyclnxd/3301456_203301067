import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:subsocial/components/post_card.dart';

class DiscoveryPostsView extends ConsumerStatefulWidget {
  const DiscoveryPostsView({Key? key, required this.postWithIndex})
      : super(key: key);

  final List postWithIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DiscoveryPostsViewState();
}

class _DiscoveryPostsViewState extends ConsumerState<DiscoveryPostsView> {
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
        _scrollToIndex(widget.postWithIndex[1]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List posts = widget.postWithIndex[0];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Discovery"),
      ),
      body: ScrollablePositionedList.builder(
        itemCount: posts.length,
        itemBuilder: (_, index) => PostCard(post: posts[index]),
        itemScrollController: _scrollController,
      ),
    );
  }
}
