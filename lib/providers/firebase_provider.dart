import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/network/firebase/auth/auth_service.dart';
import '../services/network/firebase/firestore/firestore_service.dart';
import '../services/network/firebase/storage/storage_service.dart';

final _firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final _firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final _firebaseStorageProvider =
    Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

final authServicesProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(_firebaseAuthProvider));
});

final firestoreServicesProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref.read(_firebaseFirestoreProvider));
});

final storageServicesProvider = Provider<StorageService>((ref) {
  return StorageService(ref.read(_firebaseStorageProvider));
});
