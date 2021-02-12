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

exports.onCreatePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onCreate(async (snapshot, context) => {
      const postCreated = snapshot.data();
      const userId = context.params.userId;
      const postId = context.params.postId;
      console.log("user Id: ", userId, "postId: ", postId);

      const userFollowerRef = admin
          .firestore()
          .collection("followers")
          .doc(userId)
          .collection("userFollowers");

      const querySnapshot = await userFollowerRef.get();
      console.log("got snapshot");
      querySnapshot.forEach((doc) => {
        const followerId = doc.id;
        console.log("follower Id: ", followerId);

        admin
            .firestore()
            .collection("timeline")
            .doc(followerId)
            .collection("timelinePosts")
            .doc(postId)
            .set(postCreated);
        console.log("Timeline Added");
      });
    });

exports.onUpdatePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onUpdate(async (change, context) => {
      const postUpdated = change.after.data();
      const userId = context.params.userId;
      const postId = context.params.postId;

      // 1) Get all the followers of the user who made the post
      const userFollowersRef = admin
          .firestore()
          .collection("followers")
          .doc(userId)
          .collection("userFollowers");

      const querySnapshot = await userFollowersRef.get();
      // 2) Update each post in each follower's timeline
      querySnapshot.forEach((doc) => {
        const followerId = doc.id;

        admin
            .firestore()
            .collection("timeline")
            .doc(followerId)
            .collection("timelinePosts")
            .doc(postId)
            .get()
            .then((doc) => {
              if (doc.exists) {
                doc.ref.update(postUpdated);
              }
            });
      });
    });

exports.onDeletePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onDelete(async (snapshot, context) => {
      const userId = context.params.userId;
      const postId = context.params.postId;

      // 1) Get all the followers of the user who made the post
      const userFollowersRef = admin
          .firestore()
          .collection("followers")
          .doc(userId)
          .collection("userFollowers");

      const querySnapshot = await userFollowersRef.get();
      // 2) Delete each post in each follower's timeline
      querySnapshot.forEach((doc) => {
        const followerId = doc.id;

        admin
            .firestore()
            .collection("timeline")
            .doc(followerId)
            .collection("timelinePosts")
            .doc(postId)
            .get()
            .then((doc) => {
              if (doc.exists) {
                doc.ref.delete();
              }
            });
      });
    });

exports.onCreateActivityFeedItem = functions.firestore
    .document("/feed/{userId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
      console.log("Activity Feed Item Created", snapshot.data());
      const userId = context.params.userId;
      const userRef = admin.firestore().doc(`users/${userId}`);
      const doc = await userRef.get();
      const androidNotificationToken = doc.data().androidNotificationToken;
      const createdActivityFeedItem = snapshot.data();
      if (androidNotificationToken) {
        sendNotification(androidNotificationToken, createdActivityFeedItem);
      } else {
        console.log("No Toke for user");
      }
      /**
       * Adds two numbers together.
       * @param {String} androidNotificationToken The first number.
       * @param {String} activityFeedItem The second number.
       */
      function sendNotification(androidNotificationToken, activityFeedItem) {
        let body;
        switch (activityFeedItem.type) {
          case "comment":
            body = "{$activityFeedItem.userName} replied:";
            break;
          case "Like":
            body = "{$activityFeedItem.userName} liked your post";
            break;
          case "follow":
            body = "{$activityFeedItem.userName} is following you";
            break;
          default:
            body = "something went wrong";
            break;
        }
        const message = {
          notification: {body},
          token: androidNotificationToken,
          data: {recipient: userId},
        };
        admin.messaging().send(message).then((response) => {
          console.log("Success", response);
        }).catch((error) => {
          console.log("Error", error);
        });
      }
    });
