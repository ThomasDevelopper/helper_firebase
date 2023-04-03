library helper_firebase;

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class HelperFirebaseStorage {

  HelperFirebaseStorage();


  /// Function to send a file in the storage (media).
  ///
  /// - [storageReference] is the storage reference like ref.child("Users").
  /// - [file] is the file to add in the storage.
  /// - [nameDefaultFile] (if exist) is the name of the default file. For example "default.png" for user's default picture.
  Future<String> sendFileToStorage({
    required Reference storageReference,
    required File? file,
    required String? nameDefaultFile
  }) async {
    // Initialize the file name by the nameDefaultFile
    String? fileName = nameDefaultFile;
    // Throw an exception if the file is null
    if(file==null && nameDefaultFile==null) throw Exception("If the nameDefaultFile is null, the file must be not null");
    // If the nameDefaultFile is not null
    if(file!=null) {
      // Set the child of the storage reference
      storageReference = storageReference.child(nameDefaultFile!);
    }
    else {
      // Get the file name of the file
      fileName = file!.path.split('/').last;
      // Set the child of the storage reference
      storageReference = storageReference.child(fileName);
      // Put the file into the storage
      await storageReference.putFile(file);
    }
    // Get the token of the file
    String token = (await storageReference.getDownloadURL()).split('token=').last;
    // Return the file string
    return "$fileName?alt=media&token=$token";
  }


  /// Function to delete a file from the storage.
  ///
  /// - [storageReference] is the FirebaseStorage reference, like ref.child("Users").
  /// - [fileNameInStorage] is the name of the file in the storage, like "abc.png".
  Future<void> deleteFileFromStorageWithName({
    required Reference storageReference,
    required String? fileNameInStorage
  }) async {
    // If the file is not null
    if(fileNameInStorage!=null) {
      // Set the storage reference
      storageReference = storageReference.child(fileNameInStorage);
      // Delete the image
      await storageReference.delete();
    }
  }


  /// Function to delete a file from the storage.
  ///
  /// - [storageReference] is the FirebaseStorage reference, like ref.child("Users").
  /// - [file] is the file in the storage, like "abc.png".
  Future<void> deleteFileFromStorage({
    required Reference storageReference,
    required File? file
  }) async {
    // If the file is not null
    if(file!=null) {
      // Set the storage reference
      storageReference = storageReference.child(file.path.split('/').last);
      // Delete the image
      await storageReference.delete();
    }
  }
}