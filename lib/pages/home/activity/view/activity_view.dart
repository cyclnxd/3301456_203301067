import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/providers/firebase_provider.dart';

import '../../../../services/navigation/navigation_service.dart';

typedef JsonMap = Map<String, dynamic>;

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  late final Stream<QuerySnapshot> _stream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _user = ref.watch(authServicesProvider).getCurrentUser;
    _stream = ref.watch(firestoreServicesProvider).fetchActivities(_user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activities',
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs
                .map(
                  (DocumentSnapshot document) {
                    Map<String, dynamic> user =
                        document.data()! as Map<String, dynamic>;
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
                  },
                )
                .toList()
                .cast(),
          );
        },
      ),
    );
  }
}
