import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/playlist/ShowPlayList.dart';
import 'package:movie_app/views/profile/profile_edit.dart';

import '../SplashScreen.dart';

class ProfilePage extends StatefulWidget {
  final String user_id;

  ProfilePage({@required this.user_id});

  @override
  _ProfilePageState createState() => _ProfilePageState(user_id: user_id);
}

class _ProfilePageState extends State<ProfilePage> {
  final String user_id;
  String name = "Loading...";
  String user_name = "Loading...";

  _ProfilePageState({this.user_id});


  List<Color> _startList = [
    Color(0xff608bdc),
    Color(0xff1a833d),
    Color(0xffc31432),
    Color(0xffFFE000),
    Color(0xff8E2DE2),
    Color(0xff43C6AC)
  ];
  List<Color> _endList = [
    Color(0xff3152b7),
    Color(0xff240b36),
    Color(0xff240b36),
    Color(0xff799F0C),
    Color(0xff4A00E0),
    Color(0xff191654)
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CommonData.currentUserId = user_id;

  //  fetchProfileData();
  }

  int playList;
  int followers;
  int following;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
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
                          '/users/${user_id}/playlist')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.active) {
                          //CommonData.savedPlayListSnapshot = snapshot;
                          if (snapshot.data.docs.length > 0) {
                            return playListScreen(snapshot);
                          } else {
                            return Center(
                              child: Text(
                                "No PlayList",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                        } else {
                          return CommonData.savedPlayListSnapshot == null
                              ? Center(child: CircularProgressIndicator())
                              : playListScreen(
                              CommonData.savedPlayListSnapshot);
                        }
                      }),
                ),
              )
            ],
          ),
          //i.e log out button below
          // Positioned(
          //   top:10,
          //   right: 10,
          //   child:  Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: InkWell(
          //       highlightColor: Colors.red,
          //       child: Text(
          //         'LogOut',
          //         style: TextStyle(
          //           color: Colors.redAccent,
          //           fontSize: 16,
          //           fontFamily: 'Nunito',
          //         ),
          //       ),
          //       onTap: () async {
          //         await FirebaseAuth.instance.signOut();
          //         Navigator.pushAndRemoveUntil(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => SplashScreen()),
          //                 (route) => false);
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget playListScreen(AsyncSnapshot<QuerySnapshot> snapshot) {
    int index = 1;
    return GridView.count(
      padding: EdgeInsets.symmetric(
          horizontal: 5, vertical: 8),
      crossAxisCount: 2,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 6 / 5,
      children: snapshot.data.docs
          .map((DocumentSnapshot document) {
        return InkWell(
          onTap: () =>
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ShowPlayList(
                              document.id,
                              document["movies_id"]))),
          child: buildPlayList(index++, document.id,
              document["movies_id"]),
        );
      }).toList(),
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

  Widget buildPlayList(int index, String name, List<dynamic> movieList) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                _startList[index % _startList.length],
                _endList[index % _endList.length]
              ])),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              height: 5,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "${movieList.length} movies",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
          ],
        ),
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
