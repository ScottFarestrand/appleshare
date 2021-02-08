const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreate(async (snapshot, context) => {
      console.log("Follower Created", snapshot.id);
      const userId = context.params.userId;
      // console.log(userId);
      const followerId = context.params.followerId;
      // console.log(followerId);

      // 1) Create followed users posts ref
      const followedUserPostsRef = admin
          .firestore()
          .collection("posts")
          .doc(userId)
          .collection("userPosts");


      // 2) Create following user's timeline ref
      const timelinePostsRef = admin
          .firestore()
          .collection("timeline")
          .doc(followerId)
          .collection("timelinePosts");
      // console.log("timeline ref created follower ID:", followerId);

      // 3) Get followed users posts
      const querySnapshot = await followedUserPostsRef.get();
      // console.log("Snapshot Created");

      // 4) Add each user post to following user's timeline
      // console.log("checking docs");
      querySnapshot.forEach((doc) => {
        // console.log("processing Docs");
        if (doc.exists) {
          console.log("processing Doc");
          const postId = doc.id;
          const postData = doc.data();
          timelinePostsRef.doc(postId).set(postData);
          console.log("Timeline Data Added");
        }
      });
    });


exports.onDeleteollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onDelete(async (snapshot, context) => {
      console.log("Follower Created", snapshot.id);
      const userId = context.params.userId;
      const followerId = context.params.followerId;
      console.log("User ID:", userId);
      const timelinePostsRef = admin
          .firestore()
          .collection("timeline")
          .doc(followerId)
          .collection("timelinePosts")
          .where("ownerId", "==", userId);

      const querySnapshot = await timelinePostsRef.get();

      console.log("Got Documents");
      querySnapshot.forEach((doc) => {
        console.log("deleting doc: ", doc.id);
        if (doc.exists) {
          doc.ref.delete();
        }
      });
    });
