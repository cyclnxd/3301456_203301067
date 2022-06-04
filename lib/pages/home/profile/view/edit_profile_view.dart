import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../../../../components/custom_text_field.dart';
import '../../../../constants/paddings.dart';
import '../../../../models/user/user_model.dart';
import '../../../../providers/firebase_provider.dart';
import '../../../../providers/is_loading_provider.dart';
import '../../../../services/navigation/navigation_service.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  XFile? _image;
  XFile? _imgFile;
  final _key = GlobalKey<FormState>();
  late final ImagePicker _picker;
  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _bioController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _bioController = TextEditingController();
    _passwordController = TextEditingController();
    _picker = ImagePicker();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _bioController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _user = ref.watch(authServicesProvider).getCurrentUser;
    final _userInfo =
        ref.watch(firestoreServicesProvider).fetchUserWithId(_user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<QuerySnapshot>(
        future: _userInfo,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final _futureUser = snapshot.data!.docs.first;
            _usernameController.text = _futureUser["username"];
            _nameController.text = _futureUser["name"];
            _surnameController.text = _futureUser["surname"];
            _bioController.text = _futureUser["bio"];

            return Padding(
              padding: ProjectPaddings.hLargePadding,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: _changeImage(_user),
                  ),
                  Expanded(
                    flex: 5,
                    child: _accountInfoForm(_user),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(authServicesProvider)
                              .sendPasswordResetEmail(email: _user.email!);
                          showSnackBar(context, "Email sent successfully");
                        } catch (e) {
                          showSnackBar(context, "Email could not send");
                        }
                      },
                      child: const Text("Reset Password"),
                    ),
                  ),
                  const Spacer(
                    flex: 1,
                  )
                ],
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Form _accountInfoForm(User? _user) {
    return Form(
      key: _key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomTextFormField(
            controller: _usernameController,
            hintText: 'Username',
            invalidText: 'Please enter an username',
            obscureText: false,
            inputType: TextInputType.name,
          ),
          CustomTextFormField(
            controller: _nameController,
            hintText: 'Name',
            invalidText: 'Please enter a name',
            obscureText: false,
            inputType: TextInputType.name,
          ),
          CustomTextFormField(
            controller: _surnameController,
            hintText: 'Surname',
            invalidText: 'Please enter a surname',
            obscureText: false,
            inputType: TextInputType.name,
          ),
          CustomTextFormField(
            controller: _bioController,
            hintText: 'Biography',
            invalidText: 'Please enter a biography',
            obscureText: false,
            inputType: TextInputType.text,
            isAreaText: true,
          ),
          nextButton(_user, _image),
        ],
      ),
    );
  }

  GestureDetector _changeImage(User? user) {
    return GestureDetector(
      onTap: () async {
        _imagePicker();
      },
      child: CircleAvatar(
        radius: 60.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            children: [
              _imgFile != null && !kIsWeb
                  ? Image.file(
                      File(_imgFile!.path),
                    )
                  : Image.network(
                      user?.photoURL ?? "ph_profile.jpg".phPath(),
                    ),
              Positioned(
                child: Text(
                  "Add photo",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                left: 31,
                bottom: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _imagePicker() async {
    try {
      _image = await _picker.pickImage(
        source: ImageSource.gallery,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }
    setState(() {
      _imgFile = _image;
    });
  }

  ElevatedButton nextButton(User? _user, XFile? image) {
    final _firestoreState = ref.watch(firestoreServicesProvider);
    final _storageService = ref.watch(storageServicesProvider);
    String? _imgUrl;
    return ElevatedButton(
      onPressed: ref.watch(isLoadingProvider)
          ? null
          : () async {
              if (_key.currentState!.validate()) {
                try {
                  ref.read(isLoadingProvider.notifier).changeIsLoading();
                  if (image != null) {
                    _imgUrl = await _storageService.uploadImage(
                      path: "profilePic",
                      uid: _user!.uid,
                      postId: const Uuid().v1(),
                      file: File(image.path),
                    );

                    UserModel tempUser = UserModel(
                      id: _user.uid,
                      username: _usernameController.text,
                      name: _nameController.text,
                      surname: _surnameController.text,
                      profImage: _imgUrl!,
                      bio: _bioController.text,
                      followers: [""],
                      following: [""],
                    );
                    _user.updatePhotoURL(_imgUrl);
                    _user.updateDisplayName(_usernameController.text);
                    _firestoreState.addUser(tempUser);
                    NavigationService.instance.navigateToPageClear(
                      path: '/home',
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Select photo"),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User not added"),
                    ),
                  );
                } finally {
                  ref.read(isLoadingProvider.notifier).changeIsLoading();
                }
              }
            },
      child: Center(
        child: ref.watch(isLoadingProvider)
            ? const SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(),
              )
            : const Text("Save"),
      ),
    );
  }
}
