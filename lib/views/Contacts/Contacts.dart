import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:movie_app/views/Social/Profile.dart';
import 'package:movie_app/views/playlist/ShowContactPlayList.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Services/CommonData.dart';

class Contacts extends StatefulWidget {
  // const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact> _contacts;
  bool _permissionDenied = false;

  final Permission _permission = Permission.contacts;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  @override
  void initState() {
    super.initState();
   // _fetchContacts();
    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }
  Future<List<Contact>> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts(withProperties: true);

      List<dynamic> allusers = await CommonData.getAllUsers();

      List<Contact> filteredContacts = [];
      for (var contact in contacts) {
        for (var phone in contact.phones) {
          for (var user in allusers) {
          //print("user phone number is ${user['mobile']}");
          var mobile = phone.number.replaceAll(' ', '');
          mobile = mobile.startsWith("+91")?mobile.replaceAll("+91",""):mobile;
          user['mobile'] = user['mobile'].startsWith("+91")?user['mobile'].replaceAll("+91",""):user['mobile'];
          //print("current phone number is ${mobile}");
            if (user['mobile'] == mobile) {
              contact.id = user['user_id'];
              filteredContacts.add(contact);
            }
          }
        }
      }

      //fetch contacts from firebase
      //compare with contacts


  return filteredContacts;
      //setState(() => _contacts = filteredContacts);
    }
  }

  Future requestPermission() async {
    final status = await Permission.contacts.request();

    if(status == PermissionStatus.permanentlyDenied){
      //open app setting
      AppSettings.openAppSettings();
    }
    if(status == PermissionStatus.granted){
      _fetchContacts();
    }

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
      if (_permissionDenied) return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Permission denied'),
          TextButton(onPressed: requestPermission, child: Text('Try again')),
        ],
      ));
      // if (_contacts == null) return Center(child: CircularProgressIndicator());
      return FutureBuilder<List<Contact>>(
        future: _fetchContacts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: InkWell(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      color:Colors.grey[100],
                      child: ListTile(
                        title: Text(snapshot.data[i].displayName),
                        //subtitle: Text(_contacts[i].phones[0].number)
                      ),
                    ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShowContactPlayList(
                                    snapshot.data[i].displayName,snapshot.data[i].id)));
                      },

                  ),
                ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
      return ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.all(0.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color:Colors.grey[100],
              child: ListTile(
                  title: Text(_contacts[i].displayName),
                  //subtitle: Text(_contacts[i].phones[0].number)
              ),
            ),
          ));

  }
}
