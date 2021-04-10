import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:movie_app/widgets/button.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';

import '../home/HomePage.dart';

class OtpVerfication extends StatefulWidget {
  @override
  _OtpVerficationState createState() => _OtpVerficationState();
}

class _OtpVerficationState extends State<OtpVerfication> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Lottie.asset(
                "assets/jsons/otp_verify.json",
                height: 300.0,
                width: 250.0,
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
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 10.0,
                    margin: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 40.0),
                          padding: EdgeInsets.all(20.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Verification\n\n",
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0278AE),
                                  ),
                                ),
                                TextSpan(
                                  text: "Enter the OTP send to your mobile number",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Color(0xFF373A40),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: PinEntryTextField(
                            showFieldAsBox: true,
                            fields: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Button(
                  size: size,
                  text: "Verify",
                  press: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) =>HomePage() ),
                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
