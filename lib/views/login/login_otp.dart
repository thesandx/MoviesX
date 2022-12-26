import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/views/login/otp_verify.dart';
import 'package:movie_app/widgets/button.dart';

class LoginOtp extends StatefulWidget {
  @override
  _LoginOtpState createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  @override
  void initState() {
    super.initState();
  }

  final _phoneController = TextEditingController();

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        //backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: size.height * 0.05),
                child: Lottie.asset(
                  "assets/jsons/otp.json",
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
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.black,
                                  letterSpacing: 0.5,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Login with mobile number\n\n\n",
                                    style:getTextStyle(22, Color(0xFF0278AE),FontWeight.w900),
//
                                  ),
                                  TextSpan(
                                    text: "We will send you an",
                                    style:getTextStyle(12, Color(0xFF373A40),FontWeight.normal),

                                  ),
                                  TextSpan(
                                    text: " One Time Password (OTP) ",
                                    style:getTextStyle(12, Color(0xFF373A40),FontWeight.w900),
                                  ),
                                  TextSpan(text: "on this mobile number",
                                    style:getTextStyle(12, Color(0xFF373A40),FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            Form(
                              key: formKey,
                              child: TextFormField(
                                key: ValueKey("mobile_tf"),
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                controller: _phoneController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length != 10) {
                                    return "Please Enter valid phone number";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefix: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Text('+91'),
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
                                  labelText: "Mobile",
                                  hintText: "Enter Your Mobile Number.",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Button(
                    key: ValueKey("otp_btn"),
                    size: size,
                    text: "Send OTP",
                    press: () {
                      if (formKey.currentState.validate()) {
                        final phone = _phoneController.text.trim();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OtpVerfication(phone)),
                        );
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ));
  }

  TextStyle getTextStyle(double fontSize, Color textColor,FontWeight fontWeight) {
    return TextStyle(
      color: textColor,
      fontFamily: 'Nunito',
      fontSize: fontSize,
      fontWeight: fontWeight
    );
  }
}
