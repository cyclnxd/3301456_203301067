import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/project_colors.dart';
import 'activity/view/activity_view.dart';
import 'addpost/view/add_post_view.dart';
import 'discovery/view/discovery_view.dart';
import 'feed/view/feed_view.dart';
import 'profile/view/profile_view.dart';

class HomePageView extends HookConsumerWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _pageController = usePageController();
    final _currentIndex = useState(0);
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          FeedView(),
          DiscoveryView(),
          AddPostView(),
          ActivityView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar:
          buildBottomNavbar(context, _currentIndex, _pageController),
    );
  }

  Container buildBottomNavbar(
    BuildContext context,
    ValueNotifier currentIndex,
    PageController pageController,
  ) {
    return Container(
      decoration: const BoxDecoration().copyWith(
        boxShadow: [
          BoxShadow(
            color: ProjectColors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset.zero, // changes position of shadow
          ),
        ],
      ),
      child: BottomNavigationBar(
        iconSize: MediaQuery.of(context).size.width < 500
            ? MediaQuery.of(context).size.width * 0.08
            : MediaQuery.of(context).size.width * 0.02,
        onTap: (index) {
          currentIndex.value = index;
          pageController.jumpToPage(index);
        },
        currentIndex: currentIndex.value,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search_circle),
            activeIcon: Icon(CupertinoIcons.search_circle_fill),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_outlined),
            activeIcon: Icon(Icons.add_circle),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.suit_spade),
            activeIcon: Icon(CupertinoIcons.suit_spade_fill),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: "",
          ),
        ],
      ),
    );
  }
}
