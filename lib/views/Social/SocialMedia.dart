import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/Social/MoviePost.dart';
import 'package:movie_app/views/Social/Profile.dart';

class SocialMedia extends StatefulWidget {
  @override
  _SocialMediaState createState() => _SocialMediaState();
}

class _SocialMediaState extends State<SocialMedia> {
  int _selectedItemIndex = 0;


  getFollowing() async{
    await CommonData.fetchFollwing(FirebaseAuth.instance.currentUser);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   getFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Stack(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                  "https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=100&w=640"),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 10,
                child: Icon(
                  Icons.add,
                  size: 15,
                ),
              ),
            )
          ],
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MoviePost()));
        },
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                            .where("user_id",whereIn: CommonData.followingUsers)
                          .orderBy("date", descending: true)
                          .limit(50)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 8),
                          children:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        return buildPostSection(document);
                          }).toList(),
                        );
                      }),
                ],
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Explore',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where("user_id",whereNotIn: CommonData.followingUsers)
                          .limit(50)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Something went wrong'));
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(top: 8),
                          children:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                            return buildPostSection(document);
                          }).toList(),
                        );
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildPostSection(DocumentSnapshot document) {
    return Container(
      margin: EdgeInsets.only(bottom: 8), //separtion b/w list items
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPostFirstRow(
              "https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=100&w=940",
              document),
          SizedBox(
            height: 5,
          ),
          Visibility(
            visible: document.data()['post'].toString().length>0,
            child: Text(
              "${document.data()['post'] ?? "NA"}",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          buildPostPicture(
              CommonData.tmdb_base_image_url +
                      "w400" +
                      document.data()["posterPath"] ??
                  CommonData.image_NA,
              document.data()['movie_id'],document.id),
          SizedBox(
            height: 5,
          ),
            Text(
                  "${document.data()['likes'] ?? 0} likes",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                ),
          SizedBox(
            height: 8,
          ),

        ],
      ),
    );
  }

  Row buildPostFirstRow(String urlProfilePhoto, DocumentSnapshot document) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        ProfilPage(url: urlProfilePhoto)));
              },
              child: CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(urlProfilePhoto),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(document.data()['user_id'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          snapshot.data['user_name'],
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500]),
                        )
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "loading...",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "loading...",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500]),
                      )
                    ],
                  );
                })
          ],
        ),
        Visibility(
          visible: (document.data()["user_id"]!=FirebaseAuth.instance.currentUser.uid),
          child: InkWell(
            child: Text(
              "${CommonData.followingUsers.indexOf(document.data()["user_id"]) < 0  ? "Follow":"Following"}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent
              ),
            ),
            onTap: (){
              addFollowing(document.data()["user_id"]);
            },
          ),
        )
      ],
    );
  }

  Stack buildPostPicture(String urlPost, int movie_id,String docId) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context)
              .size
              .width, //-70 height me width liya hai intresting,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(urlPost),
              )),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(
                      '/users/${FirebaseAuth.instance.currentUser.uid}/movies').where("movie_id",isEqualTo: movie_id).
                  snapshots(),
              builder: (context, snapshot) {
                if(snapshot.hasError){
                  print("error aaya hai ${movie_id}");
                }
                if (snapshot.connectionState == ConnectionState.active) {
                  //print(snapshot.data.toString() + " ${movie.id}");
                  bool val = snapshot.data.docs.length > 0 ? snapshot.data.docs[0]['liked']?? false:false;
                  return InkWell(
                    child: Icon(Icons.favorite,
                        size: 35,
                        color: val
                            ? Colors.red.withOpacity(1.0)
                            : Colors.white.withOpacity(0.7)),
                    onTap: () {
                      //print("Movie id ${movie.id} ,abhi hai  - ${CommonData.likedMovies[movie.id]} ,krenge - ${movie.id} ${CommonData.likedMovies[movie.id]?? false}");
                     addMovie(movie_id, val ?? false,docId);
                    },
                  );
                }
                else  if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator());
                }
                else{
                  return InkWell(
                    child: Icon(Icons.favorite,
                        size: 35,
                        color:Colors.white.withOpacity(0.7)),
                    onTap: () {
                      addMovie(movie_id, false,docId);
                    },
                  );
                }
              }),
        )
      ],
    );
  }

  Container buildStoryAvatar(String url) {
    return Container(
      margin: EdgeInsets.only(left: 18),
      height: 60,
      width: 60,
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), color: Colors.red),
      child: CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(url),
      ),
    );
  }

  void addMovie(int movie_id, bool isLiked,String docId) async {
    await CommonData.addLikedMovie(
        FirebaseAuth.instance.currentUser, movie_id, !isLiked);
    await CommonData.increaseLikesCount(docId,!isLiked);

  }

  void addFollowing(followingId) async{
        if(FirebaseAuth.instance.currentUser.uid == followingId){
          return;
        }
        CommonData.addFollowing(FirebaseAuth.instance.currentUser.uid, followingId, true);
  }
}
