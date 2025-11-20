import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserImage(String uid, File file) async {
    final ref = _storage.ref().child('users').child(uid).child('profile.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
