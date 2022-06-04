import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_provider.dart';
import '../../../../services/navigation/navigation_service.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  Future<QuerySnapshot>? _futureUsers;
  bool foundUser = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black12,
          ),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              contentPadding: EdgeInsets.only(bottom: 15, left: 15),
              labelText: "Search",
              border: InputBorder.none,
            ),
            onChanged: (value) {
              _futureUsers = ref
                  .read(firestoreServicesProvider)
                  .fetchUserWithUsername(value);
              value.isNotEmpty
                  ? setState(() {
                      foundUser = true;
                    })
                  : setState(() {
                      foundUser = false;
                    });
            },
          ),
        ),
      ),
      body: foundUser
          ? FutureBuilder<QuerySnapshot>(
              future: _futureUsers,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () => NavigationService.instance.navigateToPage(
                          path: "/profile",
                          data: snapshot.data!.docs[index]['id'],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              (snapshot.data! as dynamic).docs[index]
                                  ['profImage'],
                            ),
                            radius: 16,
                          ),
                          title: Text(
                            (snapshot.data! as dynamic).docs[index]['username'],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("Search User"),
                  );
                }
              },
            )
          : const Center(
              child: Text("Search User"),
            ),
    );
  }
}
