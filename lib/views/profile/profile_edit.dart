import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/home/HomePage.dart';
import 'package:movie_app/widgets/button.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
          body: ModalProgressHUD(
            inAsyncCall: CommonData.isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48,horizontal: 32),
                    child: Column(
                      children: [
                        SizedBox(height: 0),
                        Text("Welcome", style: getTextStyle(36.0, Colors.black)),
                        Text(
                          "Enter your basic details so we can  \nserve you better :)",
                          textAlign: TextAlign.center,
                          style: getTextStyle(16, Colors.black),
                        ),
                        SizedBox(height:30),
                        CompleteProfileForm(),
                        SizedBox(height: 30),
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