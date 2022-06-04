import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:subsocial/pages/home/discovery/feed/discovery_feed_view.dart';
import 'package:subsocial/pages/home/profile/view/saveds_view.dart';

import '../../components/not_found_widget.dart';
import '../../constants/navigation.dart';
import '../../pages/authentication/login/view/login_view.dart';
import '../../pages/authentication/account/view/account_info.dart';
import '../../pages/authentication/register/view/register_view.dart';
import '../../pages/home/activity/view/activity_view.dart';
import '../../pages/home/addpost/view/add_post_view.dart';
import '../../pages/home/comments/view/comments_view.dart';
import '../../pages/home/discovery/view/discovery_view.dart';
import '../../pages/home/discovery/view/search_view.dart';
import '../../pages/home/home_view.dart';
import '../../pages/home/likes/view/likes_view.dart';
import '../../pages/home/profile/view/edit_profile_view.dart';
import '../../pages/home/profile/view/posts_view.dart';
import '../../pages/home/profile/view/profile_view.dart';

abstract class INavigationService {
  Future<void> navigateToPage({required String path, Object? data}) async {}
  Future<void> navigateToPageClear(
      {required String path, Object? data}) async {}

  Route<dynamic> generateRoute(RouteSettings args);

  PageRouteBuilder normalNavigate(Widget widget, RouteSettings routeSettings);
}

class NavigationService implements INavigationService {
  static final NavigationService _instance = NavigationService._init();
  static NavigationService get instance => _instance;

  NavigationService._init();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Route<dynamic> generateRoute(RouteSettings args) {
    switch (args.name) {
      case NavigationConstants.LOGIN_VIEW:
        return normalNavigate(
          const LoginView(),
          args,
        );
      case NavigationConstants.HOME_VIEW:
        return normalNavigate(
          const HomePageView(),
          args,
        );
      case NavigationConstants.REGISTER_VIEW:
        return normalNavigate(
          const RegisterView(),
          args,
        );
      case NavigationConstants.ACCOUNT_INFO_VIEW:
        return normalNavigate(
          const AccountInfoView(),
          args,
        );
      case NavigationConstants.PROFILE_VIEW:
        return normalNavigate(
          const ProfileView(),
          args,
        );
      case NavigationConstants.DISCOVERY_VIEW:
        return normalNavigate(
          const DiscoveryView(),
          args,
        );
      case NavigationConstants.ADD_POST_VIEW:
        return normalNavigate(
          const AddPostView(),
          args,
        );
      case NavigationConstants.SEARCH_VIEW:
        return normalNavigate(
          const SearchView(),
          args,
        );
      case NavigationConstants.ACTIVITY_VIEW:
        return normalNavigate(
          const ActivityView(),
          args,
        );
      case NavigationConstants.COMMENTS_VIEW:
        return normalNavigate(
          CommentsView(post: args.arguments as QueryDocumentSnapshot),
          args,
        );
      case NavigationConstants.LIKES_VIEW:
        return normalNavigate(
          LikesView(postId: args.arguments as String),
          args,
        );
      case NavigationConstants.POSTS_VIEW:
        return normalNavigate(
          PostsView(postWithIndex: args.arguments as List),
          args,
        );
      case NavigationConstants.EDIT_PROFILE_VIEW:
        return normalNavigate(
          const EditProfileView(),
          args,
        );
      case NavigationConstants.DISCOVERY_POSTS_VIEW:
        return normalNavigate(
          DiscoveryPostsView(postWithIndex: args.arguments as List),
          args,
        );

      case NavigationConstants.SAVEDS_VIEW:
        return normalNavigate(
          const SavedsView(),
          args,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundNavigationWidget(),
        );
    }
  }

  @override
  Future<void> navigateToPage({required String path, Object? data}) async {
    await navigatorKey.currentState?.pushNamed(
      path,
      arguments: data,
    );
  }

  @override
  Future<void> navigateToPageClear({required String path, Object? data}) async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      path,
      (Route<dynamic> route) => false,
      arguments: data,
    );
  }

  @override
  PageRouteBuilder normalNavigate(Widget widget, RouteSettings routeSettings) {
    return PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => widget,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      settings: routeSettings,
    );
  }
}
