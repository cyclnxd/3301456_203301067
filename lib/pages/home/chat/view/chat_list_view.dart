import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/components/not_found_widget.dart';
import 'package:subsocial/providers/firebase_provider.dart';

import '../../../../components/chat_list_card.dart';
import '../../../../components/loading.dart';
import '../../../../models/chat/conversation_model.dart';

class ChatListView extends ConsumerStatefulWidget {
  const ChatListView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListViewState();
}

class _ChatListViewState extends ConsumerState<ChatListView> {
  @override
  Widget build(BuildContext context) {
    final _user = ref.watch(authServicesProvider).getCurrentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot<Conversation>>(
        stream:
            ref.watch(firestoreServicesProvider).fetchConversations(_user!.uid),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Loading();
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, index) {
              var conversations = snapshot.data!.docs[index];
              if (snapshot.hasData) {
                return ChatListCard(
                  conversation: conversations,
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loading();
              } else {
                return const NotFoundNavigationWidget();
              }
            },
          );
        },
      ),
    );
  }
}
