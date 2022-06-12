import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/constants/paddings.dart';
import 'package:subsocial/constants/project_colors.dart';
import 'package:subsocial/models/post/post_model.dart';
import 'package:subsocial/models/user/user_model.dart';

import 'package:subsocial/providers/firebase_provider.dart';
import 'package:subsocial/providers/theme_provider.dart';
import 'package:subsocial/services/navigation/navigation_service.dart';
import 'package:subsocial/utils/utils.dart';

import '../../../../providers/is_loading_provider.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final _uid = ModalRoute.of(context)!.settings.arguments as String?;
    final _currentUser = ref.read(authServicesProvider).getCurrentUser;

    final _userUid = _uid != null
        ? _currentUser!.uid != _uid
            ? _uid
            : _currentUser.uid
        : _currentUser!.uid;

    final Future<QuerySnapshot<UserModel>>? _userFuture =
        ref.watch(firestoreServicesProvider).fetchUserWithId(_userUid);
    final Future<QuerySnapshot<Post>>? _postFuture =
        ref.watch(firestoreServicesProvider).fetchPostWithId(_userUid);

    return FutureBuilder<QuerySnapshot<UserModel>>(
      future: _userFuture,
      builder: (_, AsyncSnapshot<QuerySnapshot<UserModel>> snapUser) {
        if (snapUser.hasData) {
          var _user = snapUser.data!.docs.first.data();
          int followers = _user.followers.length;
          int following = _user.following.length;
          return Scaffold(
            appBar: _buildAppBar(_user, _uid, _currentUser),
            body: FutureBuilder<QuerySnapshot<Post>>(
              future: _postFuture,
              builder: (_, AsyncSnapshot<QuerySnapshot<Post>> snapPost) {
                if (!snapPost.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                var _posts = snapPost.data!.docs;
                var isFollowing = _user.followers.contains(_currentUser.uid);
                return ListView(
                  children: [
                    Padding(
                      padding: ProjectPaddings.gMediumPadding,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              profileImage(_user),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildStatColumn(_posts.length, "posts"),
                                        buildStatColumn(
                                            followers - 1, "followers"),
                                        buildStatColumn(
                                            following - 1, "following"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _uid != null && _uid != _currentUser.uid
                                            ? Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var conversation = await ref
                                                            .read(
                                                                firestoreServicesProvider)
                                                            .createConversation(
                                                              _currentUser.uid,
                                                              _user.id,
                                                            );

                                                        NavigationService
                                                            .instance
                                                            .navigateToPage(
                                                          path: '/chat',
                                                          data: {
                                                            'conversation':
                                                                conversation,
                                                            'user': snapUser
                                                                .data!
                                                                .docs
                                                                .first,
                                                          },
                                                        );
                                                      },
                                                      child:
                                                          const Text("Message"),
                                                    ),
                                                    ElevatedButton(
                                                      child: !isFollowing
                                                          ? ref.watch(
                                                                  isLoadingProvider)
                                                              ? SizedBox(
                                                                  height: 15,
                                                                  width: 15,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: !ref.watch(
                                                                            themeDataProvider)
                                                                        ? ProjectColors
                                                                            .white
                                                                        : ProjectColors
                                                                            .black,
                                                                  ),
                                                                )
                                                              : const Text(
                                                                  'Follow')
                                                          : ref.watch(
                                                                  isLoadingProvider)
                                                              ? SizedBox(
                                                                  height: 15,
                                                                  width: 15,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: !ref.watch(
                                                                            themeDataProvider)
                                                                        ? ProjectColors
                                                                            .white
                                                                        : ProjectColors
                                                                            .black,
                                                                  ),
                                                                )
                                                              : const Text(
                                                                  'Unfollow'),
                                                      onPressed: ref.watch(
                                                              isLoadingProvider)
                                                          ? null
                                                          : () async {
                                                              try {
                                                                ref
                                                                    .read(isLoadingProvider
                                                                        .notifier)
                                                                    .changeIsLoading();
                                                                await ref
                                                                    .watch(
                                                                        firestoreServicesProvider)
                                                                    .followUser(
                                                                      _currentUser
                                                                          .uid,
                                                                      _user.id,
                                                                    );

                                                                setState(() {
                                                                  isFollowing =
                                                                      !isFollowing;
                                                                });
                                                              } catch (e) {
                                                                showSnackBar(
                                                                  context,
                                                                  "User could not followed",
                                                                );
                                                              } finally {
                                                                ref
                                                                    .read(isLoadingProvider
                                                                        .notifier)
                                                                    .changeIsLoading();
                                                              }
                                                            },
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox.shrink()
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(
                              top: 15,
                            ),
                            child: Text(
                              '${_user.name} ${_user.surname}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(
                              top: 1,
                            ),
                            child: Text(
                              _user.bio,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1),
                    snapPost.data!.docs.isNotEmpty
                        ? buildPosts(snapPost, _posts)
                        : Padding(
                            padding: ProjectPaddings.vMediumPadding,
                            child: Center(
                              child: Text(
                                "user hasn't shared a post yet",
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ),
                          )
                  ],
                );
              },
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  AppBar _buildAppBar(UserModel _user, String? _uid, User _currentUser) {
    return AppBar(
      centerTitle: false,
      title: Text(_user.username),
      actions: [
        _uid != null && _uid != _currentUser.uid
            ? const SizedBox.shrink()
            : IconButton(
                onPressed: () {
                  _showModalBottomSheet();
                },
                icon: const Icon(CupertinoIcons.settings),
              ),
      ],
    );
  }

  CircleAvatar profileImage(UserModel _user) {
    return CircleAvatar(
      backgroundColor: Colors.grey,
      backgroundImage: NetworkImage(
        _user.profImage,
      ),
      radius: 40,
    );
  }

  Padding buildPosts(
    AsyncSnapshot<QuerySnapshot<Post>> snap,
    List<QueryDocumentSnapshot> _posts,
  ) {
    return Padding(
      padding: ProjectPaddings.hSmallPadding,
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: snap.data!.docs.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1,
        ),
        itemBuilder: (_, index) {
          DocumentSnapshot snap = _posts[index];

          return GestureDetector(
            onTap: () {
              NavigationService.instance.navigateToPage(
                path: '/posts',
                data: {
                  'posts': _posts,
                  'title': "Posts",
                  'index': index,
                },
              );
            },
            child: CachedNetworkImage(
              imageUrl: snap['postUrl'],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> _showModalBottomSheet() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 218,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _ModalMenuButton(
                    onPressed: () {
                      Navigator.pop(context);
                      NavigationService.instance
                          .navigateToPage(path: '/edit-profile');
                    },
                    iconData: Icons.edit,
                    title: "Edit Profile",
                  ),
                  _ModalMenuButton(
                    onPressed: () {
                      Navigator.pop(context);
                      NavigationService.instance
                          .navigateToPage(path: '/saveds');
                    },
                    iconData: CupertinoIcons.bookmark,
                    title: "Saveds",
                  ),
                  _ModalMenuButton(
                    onPressed: () {
                      ref.read(themeDataProvider.notifier).changeTheme();
                    },
                    iconData: Icons.wb_sunny,
                    title: "Change Theme",
                  ),
                  _ModalMenuButton(
                    onPressed: () {
                      Navigator.pop(context);
                      NavigationService.instance
                          .navigateToPage(path: '/user-usage');
                    },
                    iconData: Icons.data_usage_rounded,
                    title: "Usage Time in App",
                  ),
                  _ModalMenuButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(authServicesProvider).signOut();
                    },
                    iconData: Icons.logout,
                    title: "Log Out",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModalMenuButton extends StatelessWidget {
  const _ModalMenuButton({
    Key? key,
    required this.onPressed,
    required this.iconData,
    required this.title,
  }) : super(key: key);

  final Function()? onPressed;
  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextButton(
        style: const ButtonStyle(
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData),
            const SizedBox(
              width: 7,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
