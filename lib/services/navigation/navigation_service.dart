import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:subsocial/models/chat/conversation_model.dart';
import 'package:subsocial/models/user/user_model.dart';
import 'package:subsocial/pages/home/activity/view/activity_post_view.dart';

import '../../components/not_found_widget.dart';
import '../../constants/navigation.dart';
import '../../models/post/post_model.dart';
import '../../pages/authentication/login/view/login_view.dart';
import '../../pages/authentication/account/view/account_info.dart';
import '../../pages/authentication/register/view/register_view.dart';
import '../../pages/home/activity/view/activity_view.dart';
import '../../pages/home/addpost/view/add_post_view.dart';
import '../../pages/home/chat/view/chat_list_view.dart';
import '../../pages/home/chat/view/chat_view.dart';
import '../../pages/home/comments/view/comments_view.dart';
import '../../pages/home/discovery/view/discovery_view.dart';
import '../../pages/home/discovery/view/search_view.dart';
import '../../pages/home/home_view.dart';
import '../../pages/home/likes/view/likes_view.dart';
import '../../pages/home/profile/editprofile/edit_profile_view.dart';
import '../../pages/home/profile/saveds/saveds_view.dart';
import '../../pages/home/profile/userusage/user_usage_view.dart';
import '../../pages/home/profile/view/profile_view.dart';
import '../../pages/post/posts_view.dart';

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
          CommentsView(post: args.arguments as QueryDocumentSnapshot<Post>),
          args,
        );
      case NavigationConstants.CHAT_VIEW:
        return normalNavigate(
          ChatView(
            conversation: (args.arguments as Map)['conversation']
                as QueryDocumentSnapshot<Conversation>,
            user: (args.arguments as Map)['user']
                as QueryDocumentSnapshot<UserModel>,
          ),
          args,
        );
      case NavigationConstants.ACTIVITY_POST_VIEW:
        return normalNavigate(
          ActivityPostView(post: args.arguments as DocumentSnapshot<Post>),
          args,
        );
      case NavigationConstants.LIKES_VIEW:
        return normalNavigate(
          LikesView(postId: args.arguments as String),
          args,
        );
      case NavigationConstants.POSTS_VIEW:
        return normalNavigate(
          PostsView(
            posts: (args.arguments as Map)['posts'],
            title: (args.arguments as Map)['title'],
            index: (args.arguments as Map)['index'],
          ),
          args,
        );
      case NavigationConstants.EDIT_PROFILE_VIEW:
        return normalNavigate(
          const EditProfileView(),
          args,
        );

      case NavigationConstants.SAVEDS_VIEW:
        return normalNavigate(
          const SavedsView(),
          args,
        );
      case NavigationConstants.CHAT_LIST_VIEW:
        return normalNavigate(
          const ChatListView(),
          args,
        );
      case NavigationConstants.USER_USAGE_VIEW:
        return normalNavigate(
          const UserUsageView(),
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
