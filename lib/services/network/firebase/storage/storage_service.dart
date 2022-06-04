import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class IStorageService {
  Future<String> uploadImage({
    required String path,
    required String postId,
    required String uid,
    required File file,
  });
  Future<void> deleteImage({
    required String path,
    required String postId,
    required String uid,
  });
}

class StorageService implements IStorageService {
  final FirebaseStorage _firebaseStorage;

  StorageService(this._firebaseStorage);

  @override
  Future<String> uploadImage({
    required String path,
    required String postId,
    required String uid,
    required File file,
  }) async {
    Reference ref = _firebaseStorage.ref().child(path).child(uid).child(postId);

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snap = await uploadTask;

    return await snap.ref.getDownloadURL();
  }

  @override
  Future<void> deleteImage({
    required String path,
    required String postId,
    required String uid,
  }) async {
    Reference ref = _firebaseStorage.ref().child(path).child(uid).child(postId);

    ref.delete();
  }
}
