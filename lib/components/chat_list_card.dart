import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/constants/paddings.dart';
import 'package:subsocial/models/chat/conversation_model.dart';
import 'package:subsocial/providers/firebase_provider.dart';
import 'package:subsocial/services/navigation/navigation_service.dart';

import '../constants/project_colors.dart';
import '../models/chat/chat_model.dart';
import '../models/user/user_model.dart';
import '../utils/utils.dart';

class ChatListCard extends ConsumerStatefulWidget {
  const ChatListCard({Key? key, required this.conversation}) : super(key: key);

  final QueryDocumentSnapshot<Conversation> conversation;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListCardState();
}

class _ChatListCardState extends ConsumerState<ChatListCard> {
  late Conversation _conversation;

  @override
  void didUpdateWidget(covariant ChatListCard oldWidget) {
    if (oldWidget.conversation.data() != widget.conversation.data()) {
      setState(() {
        _conversation = widget.conversation.data();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _conversation = widget.conversation.data();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = ref.watch(authServicesProvider).getCurrentUser;
    return Padding(
      padding: ProjectPaddings.vMediumPadding,
      child: FutureBuilder<QuerySnapshot<UserModel>>(
        future: ref
            .watch(firestoreServicesProvider)
            .fetchUserWithId(_conversation.user),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            UserModel? _user = snapshot.data!.docs.first.data();
            return GestureDetector(
              onTap: () {
                NavigationService.instance.navigateToPage(
                  path: '/chat',
                  data: {
                    'conversation': widget.conversation,
                    'user': snapshot.data!.docs.first,
                  },
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      _user.profImage,
                    ),
                  ),
                ),
                isThreeLine: true,
                trailing: IconButton(
                  onPressed: () {},
                  color: ProjectColors.gray,
                  icon: Container(
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.add_a_photo_outlined),
                  ),
                ),
                subtitle: StreamBuilder<QuerySnapshot<ChatMessages>>(
                  stream: ref.watch(firestoreServicesProvider).fetchMessages(
                        _currentUser!.uid,
                        widget.conversation.id,
                      ),
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(right: 2.0),
                            child: Text(
                              snapshot.data!.docs.first.data().content,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ProjectColors.gray,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            datePicker(
                              start: snapshot.data!.docs.first
                                  .data()
                                  .time
                                  .toDate(),
                              end: DateTime.now(),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: ProjectColors.gray,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                title: Text(_user.username),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
