import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../components/loading.dart';
import '../../../../providers/firebase_provider.dart';
import '../../../../services/navigation/navigation_service.dart';

class SavedsView extends ConsumerStatefulWidget {
  const SavedsView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SavedsViewState();
}

class _SavedsViewState extends ConsumerState<SavedsView> {
  @override
  Widget build(BuildContext context) {
    final _user = ref.watch(authServicesProvider).getCurrentUser;
    final _post = ref.watch(firestoreServicesProvider).fetchSaveds(_user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saveds"),
      ),
      body: FutureBuilder<QuerySnapshot?>(
        future: _post,
        builder: (_, snap) {
          if (snap.hasData) {
            return GridView.builder(
              shrinkWrap: true,
              itemCount: snap.data!.docs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, index) {
                var _savedPosts = snap.data!.docs;
                return GestureDetector(
                  onTap: () {
                    NavigationService.instance.navigateToPage(
                      path: '/saved-posts',
                      data: [
                        _savedPosts[index],
                        index,
                      ],
                    );
                  },
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: _savedPosts[index]["postUrl"],
                  ),
                );
              },
            );
          } else {
            return const Loading();
          }
        },
      ),
    );
  }
}
