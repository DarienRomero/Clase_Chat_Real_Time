import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FilesManager {

  FilesManager._privateConstructor();
  static final FilesManager _instance = FilesManager._privateConstructor();
  factory FilesManager() => _instance;

  final picker = ImagePicker();
  
  Future<File> getImageFromGallery() async {
    PickedFile pickedFile;
    try{
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    }catch(e){
      return null;
    }
    final File file = File(pickedFile.path);
    return file;
  }

  Future<File> getImageFromCamera() async {
    PickedFile pickedFile;
    try{
      pickedFile = await picker.getImage(
        source: ImageSource.camera, 
        preferredCameraDevice: CameraDevice.front,
      );
    }catch(e){
      return null;
    }
    File file = File(pickedFile.path);
    return file;
  }
  
}