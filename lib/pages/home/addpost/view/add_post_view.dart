import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:subsocial/components/custom_text_field.dart';
import 'package:subsocial/constants/paddings.dart';
import 'package:subsocial/extensions/image_path.dart';
import 'package:subsocial/models/post/post_model.dart';

import 'package:subsocial/providers/firebase_provider.dart';
import 'package:subsocial/providers/is_loading_provider.dart';
import 'package:subsocial/services/navigation/navigation_service.dart';
import 'package:subsocial/services/network/api/location_service.dart';
import 'package:uuid/uuid.dart';

class AddPostView extends HookConsumerWidget {
  const AddPostView({Key? key}) : super(key: key);

  Future<CroppedFile?> imageCropper(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );
  }

  Future<Position> getLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    try {
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          return Future.error('Location Not Available');
        }
      }
    } catch (e) {
      return Future.error('Permission Denied');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? location;
    ValueNotifier<CroppedFile?> _croppedFile = useState(null);
    ValueNotifier<XFile?> _image = useState(null);
    final _picker = useMemoized(() => ImagePicker());
    final _key = useMemoized(() => GlobalKey<FormState>());
    final _caption = useTextEditingController();
    final _locationController = useTextEditingController();

    Position position;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: ProjectPaddings.hMediumPadding,
        child: Center(
          child: Column(
            children: [
              const Spacer(
                flex: 1,
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      _image.value = await _picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 20);
                      _croppedFile.value =
                          await imageCropper(File(_image.value!.path));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please Select A Photo",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _croppedFile.value?.path != null
                          ? Image.file(
                              File(_croppedFile.value!.path),
                              fit: BoxFit.fill,
                            )
                          : Lottie.asset(
                              "ic_select_img.json".lottiePath(),
                            ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Form(
                      key: _key,
                      child: CustomTextFormField(
                        controller: _caption,
                        invalidText: "Must be enter a description",
                        hintText: "Description",
                        obscureText: false,
                        inputType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: TextField(
                  enabled: false,
                  readOnly: true,
                  controller: _locationController,
                  decoration: InputDecoration(
                    label: Text(location ?? "Location"),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.only(
                      top: 8.0,
                      right: 8.0,
                      left: 10.0,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  child: const Center(child: Text("Get Location")),
                  onPressed: () async {
                    position = await getLocation();
                    location =
                        await ref.read(locationServiceProvider).getGeocoding(
                              longitude: position.longitude.toString(),
                              latitude: position.latitude.toString(),
                            );
                    _locationController.text = location ?? "";
                  },
                ),
              ),
              const Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.height * 0.15,
        child: FittedBox(
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0.001,
            onPressed: _croppedFile.value == null
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a photo"),
                      ),
                    );
                  }
                : () async {
                    if (_key.currentState?.validate() != null) {
                      try {
                        final _uuid = const Uuid().v1();
                        User? user =
                            ref.read(authServicesProvider).getCurrentUser;
                        ref.watch(isLoadingProvider.notifier).changeIsLoading();

                        final resp =
                            await ref.read(storageServicesProvider).uploadImage(
                                  path: "posts",
                                  postId: _uuid,
                                  uid: user!.uid,
                                  file: File(_croppedFile.value!.path),
                                );
                        if (_locationController.text.isNotEmpty) {
                          var _locationName =
                              _locationController.text.split(',')[1];
                          var _locationPos =
                              _locationController.text.split(',').last;
                          await ref.read(firestoreServicesProvider).addPost(
                                Post(
                                  description: _caption.text,
                                  uid: user.uid,
                                  postId: _uuid,
                                  likes: 0,
                                  datePublished: Timestamp.now(),
                                  username: user.displayName!,
                                  postUrl: resp,
                                  profImage: user.photoURL!,
                                  location: '$_locationName, $_locationPos',
                                ),
                              );
                        } else {
                          await ref.read(firestoreServicesProvider).addPost(
                                Post(
                                  description: _caption.text,
                                  uid: user.uid,
                                  postId: _uuid,
                                  likes: 0,
                                  datePublished: Timestamp.now(),
                                  username: user.displayName!,
                                  postUrl: resp,
                                  profImage: user.photoURL!,
                                  location: '',
                                ),
                              );
                        }

                        NavigationService.instance
                            .navigateToPageClear(path: "/home");
                      } finally {
                        ref.read(isLoadingProvider.notifier).changeIsLoading();
                      }
                    }
                  },
            child: Lottie.asset(
              "ic_upload.json".lottiePath(),
              repeat: ref.watch(isLoadingProvider) ? true : false,
              addRepaintBoundary: false,
            ),
          ),
        ),
      ),
    );
  }
}
