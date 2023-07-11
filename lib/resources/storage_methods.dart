import '../barrel/export.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // adding image to firebase storage
  // This is the method declaration for uploadImageToStorage.
  // It takes three parameters:
  //childName (a string representing the child path in the Firebase Storage bucket),
  // file (a Uint8List representing the image data to be uploaded),
  //and isPost (a boolean indicating whether the image is being uploaded for a post).
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

        if(isPost){
          String id = Uuid().v1();
          ref = ref.child(id);
        }

// initiate the upload process
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
