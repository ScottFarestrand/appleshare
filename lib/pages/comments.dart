import 'package:flutter/material.dart';
import '../widgets/header.dart';

class Comments extends StatefulWidget {
  final String postID;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postID,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
        postID: this.postID,
        postOwnerId: this.postOwnerId,
        postMediaUrl: this.postMediaUrl,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commentsController = TextEditingController();
  final String postID;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postID,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments() {
    return Text('Comments');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: (Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentsController,
              decoration: InputDecoration(labelText: 'Write a Comment...'),
            ),
            trailing: OutlineButton(
              onPressed: () => print('add comment'),
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          )
        ],
      )),
    );
  }
}

class Comment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Comment');
  }
}
