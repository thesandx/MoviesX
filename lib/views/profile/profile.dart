import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/SplashScreen.dart';
import 'package:movie_app/views/profile/profile_edit.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(4, 9, 35, 1),
                Color.fromRGBO(39, 105, 171, 1),
              ],
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            //physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Container(
                    height: height * 0.43,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double innerHeight = constraints.maxHeight;
                        double innerWidth = constraints.maxWidth;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: innerHeight * 0.72,
                                width: innerWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 80,
                                    ),
                                    Text(
                                      name ?? "NA",
                                      style: TextStyle(
                                        color: Color.fromRGBO(39, 105, 171, 1),
                                        fontFamily: 'Nunito',
                                        fontSize: 37,
                                      ),
                                    ),
                                    Text(
                                      user_name ?? "NA",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontFamily: 'Nunito',
                                        fontSize: 25,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Followers',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 25,
                                              ),
                                            ),
                                            StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                        '/users/${FirebaseAuth.instance.currentUser.uid}/follower')
                                                    .where("liked",
                                                        isEqualTo: true)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.active) {
                                                    return Text(
                                                      '${snapshot.data.size ?? 0}',
                                                      style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            39, 105, 171, 1),
                                                        fontFamily: 'Nunito',
                                                        fontSize: 25,
                                                      ),
                                                    );
                                                  }
                                                  return Text(
                                                    '0',
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          39, 105, 171, 1),
                                                      fontFamily: 'Nunito',
                                                      fontSize: 25,
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 25,
                                            vertical: 8,
                                          ),
                                          child: Container(
                                            height: 50,
                                            width: 3,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'Following',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontFamily: 'Nunito',
                                                fontSize: 25,
                                              ),
                                            ),
                                            StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                        '/users/${FirebaseAuth.instance.currentUser.uid}/following')
                                                    .where("liked",
                                                        isEqualTo: true)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                      .connectionState ==
                                                      ConnectionState.active) {
                                                    return Text(
                                                      '${snapshot.data.size ?? 0}',
                                                      style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            39, 105, 171, 1),
                                                        fontFamily: 'Nunito',
                                                        fontSize: 25,
                                                      ),
                                                    );
                                                  }
                                                  return Text(
                                                    '0',
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          39, 105, 171, 1),
                                                      fontFamily: 'Nunito',
                                                      fontSize: 25,
                                                    ),
                                                  );
                                                })
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 110,
                              right: 20,
                              child: InkWell(
                                child: Icon(
                                  AntDesign.edit,
                                  color: Colors.grey[700],
                                  size: 30,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CompleteProfile(
                                              FirebaseAuth
                                                  .instance.currentUser)));
                                },
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 200,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            'https://googleflutter.com/sample_image.jpg'),
                                        fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: height * 0.5,
                    width: width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'My Playlist',
                            style: TextStyle(
                              color: Color.fromRGBO(39, 105, 171, 1),
                              fontSize: 27,
                              fontFamily: 'Nunito',
                            ),
                          ),
                          Divider(
                            thickness: 2.5,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: height * 0.15,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: height * 0.15,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          Divider(
                            thickness: 2.5,
                          ),
                          InkWell(
                            highlightColor: Colors.red,
                            child: Text(
                              'LogOut',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 27,
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
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
