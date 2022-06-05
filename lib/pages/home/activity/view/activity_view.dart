import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/components/activity_card.dart';
import 'package:subsocial/providers/firebase_provider.dart';

typedef JsonMap = Map<String, dynamic>;

class ActivityView extends ConsumerStatefulWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ActivityViewState();
}

class _ActivityViewState extends ConsumerState<ActivityView> {
  late final Future<QuerySnapshot> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _user = ref.watch(authServicesProvider).getCurrentUser;
    _future = ref.watch(firestoreServicesProvider).fetchActivities(_user!.uid);
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
      body: FutureBuilder<QuerySnapshot>(
        future: _future,
        builder: (_, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(children: [
            for (var actv in snapshot.data!.docs)
              ActivityCard(
                activity: actv,
              )
          ]);
        },
      ),
    );
  }
}
