import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommonData{

  static   bool isLoading = false;

  static Future<dynamic> fetchProfileData() async{

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if doc exists
    DocumentSnapshot documentSnapshot = await users.doc(FirebaseAuth.instance.currentUser.uid).get();
    if(documentSnapshot.exists){
      print(documentSnapshot.data());
      return documentSnapshot.data();
    }
    else{
      return null;
    }

  }
  static Future<bool> isUsernameAvailable(String username) async {

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('user_name', isEqualTo: username)
        .limit(1)
        .get();
    final List<QueryDocumentSnapshot> documents = result.docs;
    return documents.length == 1;

  }

  static Future<bool> checkIfUserDetailExists(User user) async{

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if doc exists
    DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();
    if(documentSnapshot.exists){
      print(documentSnapshot.data());
      if(documentSnapshot.data()['user_name']==null || documentSnapshot.data()['user_name'].toString().length<1){
        print("detail not exists");
        return false;
      }
      else{
        print("detail exists");
        return true;
      }
    }
    else{
      return false;
    }
  }

  static Future<bool> checkIfUserExists(User user) async{

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if doc exists
    DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();
    if(documentSnapshot.exists){
      print("user exists");
      return true;
    }
    else{
      print("user does not exists");
      return false;
    }
  }




  static Future<bool> createUser(User user) async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if user exists
    DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();
    if(!documentSnapshot.exists){
      //if not then add the doc
      await users
          .doc(user.uid)
          .set({
        "mobile":user.phoneNumber
      }).then((value) {
        print("user added in db");
        return true;
      })
          .catchError((error){
            print("Error:failed to add user"+error.toString());
            return false;
      });

    }
    else{
      print("user already hai");
      return true;
      //check if
    }
  }

  static Future<bool> addUserData(String name,String username){
    final FirebaseAuth auth = FirebaseAuth.instance;
    User user  = auth.currentUser;
    if(user==null){
      print("Error : user null hai");
    }


      CollectionReference users = FirebaseFirestore.instance.collection('users');
      users.doc(user.uid).update({
          "name":name,
          "user_name":username
      }).then((value){
        print("detail added ");
        return true;
      }).
        catchError((error) {
          print("Failed to add user: $error");
          return false;
      });

    }

}