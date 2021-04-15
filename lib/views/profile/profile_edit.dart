import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/home/HomePage.dart';
import 'package:movie_app/widgets/button.dart';
import '../../constants.dart';
import '../../size_config.dart';
import 'profile_form.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class CompleteProfile extends StatefulWidget {
User user;
CompleteProfile(this.user);

  @override
  _CompleteProfileState createState() => _CompleteProfileState(user);
}

class _CompleteProfileState extends State<CompleteProfile> {


  User user;
  _CompleteProfileState(this.user);



  @override
  void initState() {
    super.initState();
    setState(() {
      CommonData.isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Size size = MediaQuery.of(context).size;
    AppBar buildAppBar() {
      return AppBar(
        centerTitle: true,
        backgroundColor: Color(0xfff3f5f7),
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.only(left: kDefaultPadding),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            if(Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text("MoviesX",
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w800, color: Colors.black)),
      );
    }
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
          body: ModalProgressHUD(
            inAsyncCall: CommonData.isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 32),
                  child: Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Profile Details", style: getTextStyle(36.0, Color(0xFF0278AE))),
                      SizedBox(height:10),
                      Text(
                        "Enter your basic details so we can  \nserve you better :)",
                        textAlign: TextAlign.center,
                        style: getTextStyle(16, Colors.black),
                      ),
                      SizedBox(height:20),
                      CompleteProfileForm(),
                      SizedBox(height:10),
                      Text(
                        "By continuing your confirm that you agree \nwith our Term and Condition",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

   TextStyle getTextStyle(double fontSize,Color textColor){
    return TextStyle(
      color: textColor,
      fontFamily: 'Nunito',
      fontSize: fontSize,
    );
   }
}