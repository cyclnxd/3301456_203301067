import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsocial/components/chat_bubble.dart';
import 'package:subsocial/constants/project_colors.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/models/chat/conversation_model.dart';
import 'package:subsocial/models/user/user_model.dart';
import 'package:subsocial/providers/firebase_provider.dart';

import '../../../../components/custom_text_field.dart';
import '../../../../constants/paddings.dart';
import '../../../../models/chat/chat_model.dart';
import '../../../../utils/utils.dart';

class ChatView extends ConsumerStatefulWidget {
  const ChatView({Key? key, required this.conversation, required this.user})
      : super(key: key);

  final QueryDocumentSnapshot<Conversation> conversation;
  final QueryDocumentSnapshot<UserModel> user;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  final TextEditingController _content = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  late Conversation _conversation;
  late UserModel _user;

  @override
  void didUpdateWidget(covariant ChatView oldWidget) {
    if (oldWidget.conversation.data() != widget.conversation.data()) {
      setState(() {
        _conversation = widget.conversation.data();
      });
    }
    if (oldWidget.user.data() != widget.user.data()) {
      setState(() {
        _user = widget.user.data();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    _conversation = widget.conversation.data();
    _user = widget.user.data();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = ref.watch(authServicesProvider).getCurrentUser;
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              _user.profImage,
            ),
            radius: 18,
          ),
          title: Text(
            _user.name,
          ),
          subtitle: Text(
            _user.username,
            style: const TextStyle(
              fontSize: 11,
              color: ProjectColors.gray,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<ChatMessages>>(
        stream: ref
            .watch(firestoreServicesProvider)
            .fetchMessages(_currentUser!.uid, widget.conversation.id),
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              reverse: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (_, int index) {
                var messageData = snapshot.data!.docs[index];
                bool _isCurentUser =
                    messageData.data().idFrom == _currentUser.uid;
                return ChatBubble(
                  text: messageData.data().content,
                  isCurrentUser: _isCurentUser,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _buildMessageSendBox(context, _currentUser),
    );
  }

  SafeArea _buildMessageSendBox(BuildContext context, User _currentUser) {
    return SafeArea(
      child: Container(
        height: kToolbarHeight,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                _currentUser.photoURL ?? "ph_profile".phPath(),
              ),
              radius: 18,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Form(
                  key: _key,
                  child: CustomTextFormField(
                    controller: _content,
                    hintText: 'Text here',
                    isAreaText: false,
                    inputType: TextInputType.text,
                    invalidText: '',
                    obscureText: false,
                    border: false,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_key.currentState!.validate()) {
                  try {
                    ref.read(firestoreServicesProvider).sendMessage(
                          _currentUser.uid,
                          _user.id,
                          widget.conversation.id,
                          ChatMessages(
                            content: _content.text,
                            idFrom: _currentUser.uid,
                            idTo: _user.id,
                            time: Timestamp.now(),
                            type: 1,
                          ),
                        );
                    _content.clear();
                    setState(() {});
                  } catch (e) {
                    showSnackBar(context, "Could not add comment.");
                  }
                }
              },
              child: Container(
                padding: ProjectPaddings.gSmallPadding,
                child: const Icon(Icons.send_rounded),
              ),
            )
          ],
        ),
      ),
    );
  }
}
