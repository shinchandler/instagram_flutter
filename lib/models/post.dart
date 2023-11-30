import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final List<String> likes;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profimage;

  Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.likes,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profimage,
  });

  // Named constructor for creating a Post instance from a map
  Post.fromMap(Map<String, dynamic> map)
      : description = map["description"],
        uid = map["uid"],
        likes = List<String>.from(map["likes"]),
        postId = map["postId"],
        datePublished = (map["datePublished"] as Timestamp).toDate(),
        username = map["username"],
        postUrl = map['postUrl'],
        profimage = map['profimage'];

  // Named constructor for creating a Post instance from a Firestore snapshot
  Post.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data() as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "likes": likes,
        "username": username,
        "postId": postId,
        "datePublished": datePublished,
        'postUrl': postUrl,
        'profimage': profimage,
      };
}
