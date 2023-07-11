import 'package:instagram/barrel/export.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profileImage,
  ) async {
    String res = "Some error occurred ";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      //generate universally unique identifiers (UUIDs) based on time for the postId.
      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profileImage: profileImage,
        likes: [],
      );

      // upload the Post object(post) to Firestore by converting it to JSON
      //and setting it as the data for the document with the postId as the unique identifier within the "posts" collection.

      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          "likes": FieldValue.arrayRemove(
            [uid],
          ),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          "likes": FieldValue.arrayUnion(
            [uid],
          ),
        });
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    String res = "Some error occurred ";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      }
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // deleting the post
  Future<String> deletePost(String postId) async {
    String res = 'some error occurred';
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'deleted';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Future<String> followUser(String uid, String followId) async {
  //   String res = 'some error occurred';
  //   try {
  //     DocumentSnapshot snap =
  //         await _firestore.collection('users').doc(uid).get();
  //     List following = (snap.data()! as dynamic)['following'];

  //     if (following.contains(followId)) {
  //       await _firestore.collection('users').doc(followId).update({
  //         'followers': FieldValue.arrayRemove([uid]),
  //       });
  //       await _firestore.collection('users').doc(uid).update({
  //         'following': FieldValue.arrayRemove([followId]),
  //       });
  //     } else {
  //       await _firestore.collection('users').doc(followId).update({
  //         'followers': FieldValue.arrayUnion([uid]),
  //       });
  //       await _firestore.collection('users').doc(uid).update({
  //         'following': FieldValue.arrayUnion([followId]),
  //       });
  //     }
  //   } catch (e) {
  //     res = e.toString();
  //   }
  //   return res;
  // }

  Stream<String> followUser(String uid, String followId) async* {
  String res = 'some error occurred';
  try {
    DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
    List following = (snap.data()! as dynamic)['following'];

    if (following.contains(followId)) {
      await _firestore.collection('users').doc(followId).update({
        'followers': FieldValue.arrayRemove([uid]),
      });
      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayRemove([followId]),
      });
    } else {
      await _firestore.collection('users').doc(followId).update({
        'followers': FieldValue.arrayUnion([uid]),
      });
      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayUnion([followId]),
      });
    }
    res = 'success';
  } catch (e) {
    res = e.toString();
  }
  yield res;
}

}
