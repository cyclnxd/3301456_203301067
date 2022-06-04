import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/providers/firebase_provider.dart';

import '../../../../services/navigation/navigation_service.dart';

class LikesView extends ConsumerStatefulWidget {
  const LikesView({Key? key, required this.postId}) : super(key: key);

  final String postId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LikesViewState();
}

class _LikesViewState extends ConsumerState<LikesView> {
  late final Future<QuerySnapshot>? _future;

  @override
  void initState() {
    _future = ref.read(firestoreServicesProvider).fetchLikes(widget.postId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Likes',
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _future,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (_, index) {
                var user = snapshot.data!.docs[index];
                return GestureDetector(
                  onTap: () {
                    NavigationService.instance.navigateToPage(
                      path: "/profile",
                      data: user["uid"],
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          user["profilePic"],
                        ),
                      ),
                    ),
                    title: Text(
                      user["username"],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
