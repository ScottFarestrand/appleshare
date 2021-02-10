// import 'dart:html'
import 'package:appleshare/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/progress.dart';
import '../widgets/post.dart';
import '../models/user.dart';
import '../widgets/header.dart';
import '../pages/search.dart';

final CollectionReference usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot followingSnapShot = await followingRef
        .document(currentUser.id)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingList =
          followingSnapShot.documents.map((doc) => doc.documentID).toList();
    });
  }

  getTimeline() async {
    print(widget.currentUser.id);
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    print("Got Docs");
    List<Post> posts =
        snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    print("got Lists");
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      print("Circular");
      return circularProgress();
    } else if (posts.isEmpty) {
      print("empty");
      return buildUsersToFollow();
    }
    return ListView(children: posts);
  }

  buildUsersToFollow() {
    return StreamBuilder(
        stream: usersRef
            .orderBy("timestamp", descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            final bool isAuthUser = currentUser.id == user.id;
            if (isAuthUser) {
              return Text('');
            }
            if (followingList.contains(user.id)) {
              return Text('');
            }
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          });
          return Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        "Users to Follow",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30,
                        ),
                      )
                    ],
                  ),
                ),
                Column(children: userResults),
              ],
            ),
          );
        });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, titleText: "Timeline"),
      body: RefreshIndicator(
        onRefresh: () => getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
