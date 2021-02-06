import 'package:appleshare/widgets/header.dart';

import '../widgets/post.dart';
import '../widgets/progress.dart';
import '../pages/home.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
          .document(userId)
          .collection('userPosts')
          .document(postId)
          .get(),
      builder: (context, snapShot) {
        if (!snapShot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapShot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
