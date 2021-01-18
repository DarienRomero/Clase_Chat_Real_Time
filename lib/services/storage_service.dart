import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService{

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  firebase_storage.UploadTask initateUploading(String storagePath, File archivo) {
    firebase_storage.UploadTask task = storage.ref(storagePath).putFile(archivo);
    return task;
  }

  Future<void> uploadFile(String path, File archivo) async {
    firebase_storage.UploadTask task = initateUploading(path, archivo);
    try {
      // Storage tasks function as a Delegating Future so we can await them.
      firebase_storage.TaskSnapshot snapshot = await task;
      print('Uploaded ${snapshot.bytesTransferred} bytes.');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
      }
    }
  }
  Future<String> getDownloadURL(String storagePath) async {
    final String downloadURL = await storage.ref(storagePath).getDownloadURL();
    return downloadURL;
  }
}