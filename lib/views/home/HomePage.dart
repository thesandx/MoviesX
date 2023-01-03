import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/Contacts/Contacts.dart';
import 'package:movie_app/views/Social/Profile.dart';
import 'package:movie_app/views/Social/SocialMedia.dart';
import 'package:movie_app/views/home/Feed.dart';
import 'package:movie_app/widgets/SearchBar.dart';

import '../../constants.dart';
import '../SplashScreen.dart';
import '../profile/profile_edit.dart';

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
  String name = "Loading...";
  String user_name = "Loading...";

  bool _flexibleUpdateAvailable = false;



  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void fetchProfileData() async {
    dynamic json = await CommonData.fetchProfileData();
    setState(() {
      name = json['name'] ?? "NA";
      user_name = json['user_name'] ?? "NA";
    });
  }

  @override
  void initState() {
    super.initState();
    CommonData.addDefaultPlaylist(user);
    fetchProfileData();
    currentIndex = 0;
    checkForUpdate();
  }




  changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }


  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    // print("method call kiya");
    InAppUpdate.checkForUpdate().then((updateInfo) {
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (CommonData.force_update && updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              //App Update successful
              showSnack("Success!");
            }
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          //Perform flexible update
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              //App Update successful
              InAppUpdate.completeFlexibleUpdate();
              showSnack("Success!");
            }
          });
        }
      }
    }).catchError((e) {
      showSnack(e.toString());
    });
  }



  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Do you want to exit the app?'),
                actions: <Widget>[
                  ElevatedButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shadowColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    child: Text(
                      'Exit',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      shadowColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });

        return value == true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawerEnableOpenDragGesture: false,
        appBar: buildAppBar(),
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: buildDrawerHeader(context)
              ),
              buildMenuItems(context)
            ],
          ),
        ),
        //backgroundColor: Colors.white,
        body: getCurrentPage(),
        bottomNavigationBar:
            Container(height: 60, child: BottomNavigationBar()),
      ),
    );
  }

  Widget buildDrawerHeader(BuildContext context){
    return  Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 15),
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.2),
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
      ],
    );
  }

  Widget buildMenuItems(BuildContext context){
    return Container(
        padding: EdgeInsets.all(24),
      child: Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            leading: const Icon(Icons.edit,
              color: Colors.blueAccent,
            ),
            title: const Text("Edit Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent
              ),
            ),
            onTap: (){
              Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CompleteProfile(
                                FirebaseAuth.instance.currentUser)));
                  },
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded,
                color: Colors.redAccent
            ),
            title: const Text("Log Out",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent
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
    );
  }

  Widget getCurrentPage() {
    if (currentIndex == 1) {
      return ProfilePage(user_id:FirebaseAuth.instance.currentUser.uid);
    }
    if(currentIndex==0){
      return Feed();
    }
    if(currentIndex==2){
      //return ProfileScreen();
      return Contacts();
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
            Icons.trending_up_rounded,
            color: iconColor,
          ),
          activeIcon: Icon(
            Icons.trending_up,
            color: iconActiveColor,
          ),
          title: Text('Explore', style: style),
        ),
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
          title: Text('Playlist', style: style),
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
          title: Text('Contacts', style: style),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Color(0xfff3f5f7),
      elevation: 0,
      leading:
        IconButton(
          padding: EdgeInsets.only(left: kDefaultPadding),
          icon: SvgPicture.asset("assets/icons/menu.svg"),
          onPressed: () {
            //print("button press kiya");
            fetchProfileData();
            _scaffoldKey.currentState.openDrawer();
          },
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
          onPressed: () {
            showSearch(context: context, delegate: MovieSearch());
          },
        ),
      ],
    );
  }
}
