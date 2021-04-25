import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/profile/profile_edit.dart';

import '../SplashScreen.dart';

class ProfilPage extends StatefulWidget {
  final String url;

  ProfilPage({@required this.url});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String name = "Loading...";
  String user_name = "Loading...";

  void fetchProfileData() async {
    dynamic json = await CommonData.fetchProfileData();
    setState(() {
      name = json['name'] ?? "NA";
      user_name = json['user_name'] ?? "NA";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 15),
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 20,
                      )
                    ],
                  ),
                child: CircleAvatar(
                  backgroundColor: Colors.blue.shade800,
                  child: Text('${name[0]}',
                    style: TextStyle(
                      fontSize: 48,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
//          Hero(
//            tag: widget.url,
//            child: Container(
//              margin: EdgeInsets.only(top: 35),
//              height: 80,
//              width: 80,
//              decoration: BoxDecoration(
//                borderRadius: BorderRadius.circular(40),
//                boxShadow: [
//                  BoxShadow(
//                    color: Colors.black.withOpacity(0.2),
//                    spreadRadius: 5,
//                    blurRadius: 20,
//                  )
//                ],
//                image: DecorationImage(
//                  fit: BoxFit.cover,
//                  image: NetworkImage(widget.url),
//                ),
//              ),
//            ),
//          ),
              SizedBox(
                height: 10,
              ),
              Text(
                name ?? "NA",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user_name ?? " NA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompleteProfile(
                                FirebaseAuth.instance.currentUser)));
                  },
                  child: Text("Edit Profile")),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(
                              '/users/${FirebaseAuth.instance.currentUser.uid}/movies')
                          .where("liked", isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.active) {
                          return buildStatColumn(
                              '${snapshot.data.size ?? 0}', "Movies");
                        } else {
                          return buildStatColumn("...", "Movies");
                        }
                      }),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(
                              '/users/${FirebaseAuth.instance.currentUser.uid}/follower')
                          .where("liked", isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.active) {
                          return buildStatColumn(
                              '${snapshot.data.size ?? 0}', "Followers");
                        } else {
                          return buildStatColumn("...", "Followers");
                        }
                      }),
                  StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(
                              '/users/${FirebaseAuth.instance.currentUser.uid}/following')
                          .where("liked", isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.active) {
                          return buildStatColumn(
                              '${snapshot.data.size ?? 0}', "Following");
                        } else {
                          return buildStatColumn("...", "Following");
                        }
                      }),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(left: 8, right: 8, top: 8),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25))),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(
                              '/users/${FirebaseAuth.instance.currentUser.uid}/movies')
                          .where("liked", isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.active) {
                          if (snapshot.data.docs.length > 0) {
                            return GridView.count(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                              crossAxisCount: 2,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 5 / 6,
                              children: snapshot.data.docs
                                  .map((DocumentSnapshot document) {
                                return buildPictureCard(
                                    CommonData.tmdb_base_image_url +
                                            "w300" +
                                            document.data()["poster"] ??
                                        CommonData.image_NA);
                              }).toList(),
                            );
                          } else {
                            return Center(
                              child: Text(
                                "No liked movie",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                ),
              )
            ],
          ),
          Positioned(
            top:10,
            right: 10,
            child:  Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                highlightColor: Colors.red,
                child: Text(
                  'LogOut',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontFamily: 'Nunito',
                  ),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SplashScreen()),
                          (route) => false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Card buildPictureCard(String url) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(url),
            )),
      ),
    );
  }

  Column buildStatColumn(String value, String title) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
