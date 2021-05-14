// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:movie_app/main.dart';
import 'package:movie_app/models/Results.dart';
import 'package:movie_app/views/login/login_otp.dart';

void main() {
  test("Movie should return name as expected", (){
    //Arrange
      Results results = Results(title: "Ganga");

      //Act

      //Assert
      expect(results.title,"Ganga");
  });
  
  testWidgets("Material app testing ", (WidgetTester tester) async{

    await tester.runAsync(() async {

      // test code here
      await tester.pumpWidget(MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);

      //link - https://stackoverflow.com/questions/52176777/how-to-wait-for-a-future-to-complete-in-flutter-widget-test

    });


   // await tester.pumpAndSettle();
  });


  testWidgets("Login Page valid mobile testing ", (WidgetTester tester) async{

    await tester.runAsync(() async {

      // test code here
      await tester.pumpWidget(MaterialApp(

        home:LoginOtp(),

      ));

      final mobileNum = find.byKey(ValueKey("mobile_tf"));
      final sendBtn = find.byKey(ValueKey("otp_btn"));

      await tester.enterText(mobileNum, "7983873235");
      await tester.tap(sendBtn);

      // Rebuild the widget after the state has changed.
      await tester.pump();

      // Expect to find the item on screen.
      expect(find.text('Please Enter valid phone number'), findsNothing);

      //link - https://stackoverflow.com/questions/52176777/how-to-wait-for-a-future-to-complete-in-flutter-widget-test

    });


    // await tester.pumpAndSettle();
  });


}
