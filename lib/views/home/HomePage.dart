import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_app/views/Social/SocialMedia.dart';
import 'package:movie_app/views/home/Feed.dart';
import 'package:movie_app/views/profile/profile.dart';
import '../../constants.dart';

class HomePage extends StatefulWidget {
  User user;
  HomePage(this.user);
  @override
  _HomePageState createState() => _HomePageState(user);
}

class _HomePageState extends State<HomePage> {
  User user;
  _HomePageState(this.user);
  int currentIndex;

  @override
  void initState() {
    super.initState();
    saveUserData();
    currentIndex = 0;
  }

  void saveUserData() async{

    await FirebaseFirestore.instance.collection("users")
        .doc(user.uid)
        .set({
          "mobile":user.phoneNumber
    }).then((value) => print("user added in db"))
        .catchError((error)=>print("Error:failed to add user"+error.toString()));
  }



  changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: kTextLightColor,
      body: getCurrentPage(),
      bottomNavigationBar: Container(height: 60, child: BottomNavigationBar()),
    );
  }

  Widget getCurrentPage() {
    if (currentIndex == 1) {
      return Feed();
    }
    if(currentIndex==0){
      return SocialMedia();
    }
    if(currentIndex==2){
      return ProfileScreen();
    }
  }

  Widget BottomNavigationBar() {
    const TextStyle style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black);
    const Color iconColor = Colors.grey;
    const Color iconActiveColor = Colors.black;
    return BubbleBottomBar(
      opacity: 0.2,
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32.0),
        topRight: Radius.circular(32.0),
      ),
      currentIndex: currentIndex,
      hasInk: true,
      inkColor: Colors.black12,
      hasNotch: false, //border radius doesn't work when the notch is enabled.
      onTap: changePage,
      items: [
        BubbleBottomBarItem(
          backgroundColor: Colors.grey,
          icon: Icon(
            Icons.dashboard_outlined,
            color: iconColor,
          ),
          activeIcon: Icon(
            Icons.dashboard_rounded,
            color: iconActiveColor,
          ),
          title: Text('Feed', style: style),
        ),
        BubbleBottomBarItem(
          backgroundColor: Colors.grey,
          icon: Icon(
            Icons.favorite_border_rounded,
            color: iconColor,
          ),
          activeIcon: Icon(
            Icons.favorite,
            color: iconActiveColor,
          ),
          title: Text('Favorite', style: style),
        ),
        BubbleBottomBarItem(
          backgroundColor: Colors.grey,
          icon: Icon(
            Icons.account_circle_outlined,
            color: iconColor,
          ),
          activeIcon: Icon(
            Icons.account_circle_rounded,
            color: iconActiveColor,
          ),
          title: Text('Profile', style: style),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Color(0xfff3f5f7),
      elevation: 0,
      leading: IconButton(
        padding: EdgeInsets.only(left: kDefaultPadding),
        icon: SvgPicture.asset("assets/icons/menu.svg"),
        onPressed: () {},
      ),
      title: Text("MoviesX",
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w800, color: Colors.black)),
      actions: <Widget>[
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
          icon: SvgPicture.asset("assets/icons/search.svg"),
          onPressed: () {},
        ),
      ],
    );
  }
}
