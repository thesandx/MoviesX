import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/home/HomePage.dart';
import 'package:movie_app/widgets/button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../default_button.dart';


class CompleteProfileForm extends StatefulWidget {

  @override
  _CompleteProfileFormState createState() => _CompleteProfileFormState();
}

class _CompleteProfileFormState extends State<CompleteProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> errors = [];
  String fullName;
  String userName;
  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  bool showError = false;





  String error = "error";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildNameFormField(),
          SizedBox(height: 30),
          buildUserNameFormField(),
          Visibility(
            visible: showError,
            child: Text("Userame already exists",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontFamily: 'Nunito',
              ),
            ),
          ),

          SizedBox(height: 60),
          //FormError(errors: errors),
          SizedBox(height: 20),
          //button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(30)),
//              color: Colors.blue,
              onPressed: () {
                addUserData(context);
              },
              child: Text(
                  "Complete Profile",
                  style: getTextStyle(24, Colors.white)
              ),
              style: ButtonStyle(
                backgroundColor:MaterialStateProperty.all<Color>(Colors.blue),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)
                  ),
              ),
            ),
          )
          ),

//          DefaultButton(
//            text: "continue",
//            press: () {
//              if (_formKey.currentState.validate()) {
//                //Navigator.pushNamed(context, OtpScreen.routeName);
//              }
//            },
//          ),
        ],
      ),
    );
  }

  TextStyle getTextStyle(double fontSize, Color textColor) {
    return TextStyle(
      color: textColor,
      fontFamily: 'Nunito',
      fontSize: fontSize,
    );
  }

  void addUserData(BuildContext context) async{
    setState(() {
      CommonData.isLoading= true;
    });
    if(_formKey.currentState.validate()) {
      fullName = _nameController.text.trim();
      userName = '@'+_userNameController.text.trim();
      bool val = await CommonData.isUsernameAvailable(userName);
      if(val){
        setState(() {
          showError = true;
          CommonData.isLoading = false;
        });
        return;
      }
      bool value = await CommonData.addUserData(fullName, userName);
      setState(() {
        CommonData.isLoading= false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(FirebaseAuth.instance.currentUser)),
          (router)=>false
      );
    }
  }









  TextFormField buildUserNameFormField() {
    return TextFormField(
      controller: _userNameController,
      onSaved: (newValue) => userName = newValue,

      validator: (value){
        if (value == null ||
            value.isEmpty ||
            value.length == 0) {
          //addError(error: error);
          return "username can't be empty";
        }
        return null;
      },
      decoration: InputDecoration(
        prefix: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.alternate_email,
            color: Colors.grey[700],
            size: 20,
          ),
        ),

        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0)),
        labelText: "User Name",
        hintText: "Enter Your User name",
        // floatingLabelBehavior: FloatingLabelBehavior.always
      ),
    );
  }

  TextFormField buildNameFormField() {
    return TextFormField(
      controller: _nameController,
      onSaved: (newValue) => fullName = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          return null;
        }
        return null;
      },
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            value.length == 0) {
          //addError(error: error);
          return "Name can't be empty";;
        }
        return null;
      },
      decoration: InputDecoration(
        prefix: Icon(
          AntDesign.user,
          color: Colors.grey[700],
          size: 30,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFD4D4D4),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFD4D4D4),
            width: 1.0,
          ),
        ),
        labelText: "Full Name",
        hintText: "Enter Your Full Name",
        // floatingLabelBehavior: FloatingLabelBehavior.always
      ),

    );
  }
}