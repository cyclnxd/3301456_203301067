import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/constants/paddings.dart';

import 'package:subsocial/providers/firebase_provider.dart';
import 'package:subsocial/services/navigation/navigation_service.dart';

class DiscoveryView extends ConsumerStatefulWidget {
  const DiscoveryView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiscoveryViewState();
}

class _DiscoveryViewState extends ConsumerState<DiscoveryView> {
  bool isShowUsers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () =>
              NavigationService.instance.navigateToPage(path: '/search'),
          child: Padding(
            padding: ProjectPaddings.vMediumPadding,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black12,
              ),
              child: const TextField(
                enabled: false,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.only(bottom: 15, left: 15),
                  labelText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: ProjectPaddings.hSmallPadding + ProjectPaddings.vSmallPadding,
        child: FutureBuilder<QuerySnapshot>(
          future: ref.watch(firestoreServicesProvider).fetchPosts(),
          builder: (_, snap) {
            if (snap.hasData) {
              final _posts = snap.data!.docs;
              return GridView.builder(
                shrinkWrap: true,
                itemCount: _posts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 6 : 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () {
                      NavigationService.instance.navigateToPage(
                        path: '/posts',
                        data: {
                          'posts': _posts,
                          'title': "Discovery",
                          'index': index,
                        },
                      );
                    },
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      imageUrl: _posts[index]["postUrl"],
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
