import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../pages/home.dart';
import '../pages/profile.dart';
import '../widgets/progress.dart';
import '../models/user.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;

  handleSearch(String query) {
    print('searching');
    Future<QuerySnapshot> users = usersRef
        .where("displayName", isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch() {
    print('clearing');
    searchController.clear();
  }

  AppBar buildSearchScreen() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search for a User",
          filled: true,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28,
          ),
          suffix: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
            // onPressed: () {
            //   clearSearch();
            // },
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container buildNoContent() {
    final orientaton = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              // height: 300,
              height: orientaton == Orientation.portrait ? 300.0 : 200.0,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 60.0,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    print("Getting Future");
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> searchResults = [];
        print(snapshot.data.documents);
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(children: searchResults);
      },
    );
  }

 bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
        appBar: buildSearchScreen(),
        body: searchResultsFuture == null
            ? buildNoContent()
            : buildSearchResults());
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                backgroundColor: Colors.grey,
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.white54,
          ),
        ],
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
