import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/components/not_found_widget.dart';

import '../../../../components/loading.dart';
import '../../../../providers/firebase_provider.dart';
import '../../../../services/navigation/navigation_service.dart';

final savedPostsProvider = FutureProvider<QuerySnapshot?>((ref) async {
  QuerySnapshot? _savedPosts;
  final _user = ref.watch(authServicesProvider).getCurrentUser;
  await ref.watch(firestoreServicesProvider).fetchSaveds(_user!.uid)!.then(
    (value) {
      value.docs.map(
        (e) => e.get("post").get().then((el) => _savedPosts = el),
      );
    },
  );
  return _savedPosts;
});

class SavedsView extends ConsumerStatefulWidget {
  const SavedsView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SavedsViewState();
}

class _SavedsViewState extends ConsumerState<SavedsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saveds"),
      ),
      body: ref.watch(savedPostsProvider).when(
            data: (data) {
              return GridView.builder(
                shrinkWrap: true,
                itemCount: data!.docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 6 : 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (_, index) {
                  var _savedPosts = data.docs;
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
            },
            error: (_, __) => const NotFoundNavigationWidget(),
            loading: () => const Loading(),
          ),
    );
  }
}
