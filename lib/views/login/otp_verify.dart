import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/views/profile/profile_edit.dart';
import 'package:movie_app/widgets/button.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';

import '../home/HomePage.dart';

class OtpVerfication extends StatefulWidget {
  final String phone;

  OtpVerfication(this.phone);

  @override
  _OtpVerficationState createState() => _OtpVerficationState(phone);
}

class _OtpVerficationState extends State<OtpVerfication> {
  final String phone;
  bool _isLoading = false;
  bool _otpSent = false;

  _OtpVerficationState(this.phone);

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget showSnackbar(String msg) {
    return SnackBar(
        content: Text(
      msg,
      style: GoogleFonts.nunito(
        //textStyle: Theme.of(context).textTheme.display1,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        //fontStyle: FontStyle.italic,
      ),
    ));
  }

  Future<bool> manualVerify() async {
    AuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: _verificationCode, smsCode: _otp);
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(authCredential);
      User user = userCredential.user;
      gotoNextScreen(context, user);
    } catch (e) {
      // TODO
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(showSnackbar("Invalid OTP"));
    }
  }

  String _verificationCode;
  String _otp;

  Future<bool> sendOTP(String phoneNumber, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: "+91" + phoneNumber,
        timeout: Duration(seconds: 120),

        //for_automatic verification
        verificationCompleted: (AuthCredential credential) async {
          UserCredential userCredential =
              await _auth.signInWithCredential(credential);

          User user = userCredential.user;
          gotoNextScreen(context, user);
        },
        verificationFailed: (FirebaseAuthException authException) {
          print("authentication failed " + authException.message);
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context)
              .showSnackBar(showSnackbar("Something went wrong"));
          Navigator.of(context).pop();
        },
        //manual_verification
        codeSent: (String verificationId, [int forceResendingToken]) {
          print("code sent manual");
          setState(() {
            _verificationCode = verificationId;
            _otpSent=true;
            ScaffoldMessenger.of(context)
                .showSnackBar(showSnackbar("OTP Sent"));
          });
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sendOTP(phone, context);
  }

  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      //backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        opacity: 0.1,
        color: Colors.blue,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: size.height * 0.05),
                child: Lottie.asset(
                  "assets/jsons/otp_verify.json",
                  height: size.height * 0.4,
                  alignment: Alignment.bottomCenter,
                ),
              ),
              Stack(
                children: [
                  Container(
                    height: size.height * 0.45,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10.0,
                          spreadRadius: 0.0,
                          offset: Offset(2.0, 5.0),
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 10.0,
                      margin: EdgeInsets.all(12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Verification\n\n",
                                    style:getTextStyle(22, Color(0xFF0278AE),FontWeight.w900),
                                  ),
                                  TextSpan(
                                    text:
                                        _otpSent?"Enter the OTP sent to +91${phone}":"Sending OTP to +91${phone}",
                                    style:getTextStyle(16, Color(0xFF373A40),FontWeight.normal),

                                  ),
                                ],
                              ),
                            ),
                            PinEntryTextField(
                              showFieldAsBox: true,
                              fields: 6,
                              onSubmit: (String pin) {
                                _otp = pin;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Button(
                    size: size,
                    text: "Verify",
                    press: () {
                      manualVerify();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  gotoNextScreen(BuildContext context, User user) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (user != null) {
        bool userCreate = await CommonData.createUser(user) ?? true;
        if (userCreate) {
          CollectionReference movies = FirebaseFirestore.instance.collection('/users/'+user.uid+'/movies');
          await CommonData.fetchFollwing(FirebaseAuth.instance.currentUser);
          bool val = await CommonData.retriveAPIKey();
          bool isDetail = await CommonData.checkIfUserDetailExists(user);

          if (isDetail) {

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user)),
              (route) => false,
            );
          } else {


            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => CompleteProfile(user)),
              (route) => false,
            );
          }
        } else {
          showSnackbar("User not created");
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

  }

  TextStyle getTextStyle(
      double fontSize, Color textColor, FontWeight fontWeight) {
    return TextStyle(
        color: textColor,
        fontFamily: 'Nunito',
        fontSize: fontSize,
        fontWeight: fontWeight);
  }
}
