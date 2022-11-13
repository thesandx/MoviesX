import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

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
    _fetchContacts();
    _listenForPermissionStatus();
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }
  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
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
      if (_contacts == null) return Center(child: CircularProgressIndicator());
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
