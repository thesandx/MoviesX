import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class Contacts extends StatefulWidget {
  // const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  List<Contact> _contacts;
  bool _permissionDenied = false;
  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }
  Future _fetchContacts() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
    } else {
      final contacts = await FlutterContacts.getContacts();
      setState(() => _contacts = contacts);
    }
  }
  @override
  Widget build(BuildContext context) {
      if (_permissionDenied) return Center(child: Text('Permission denied'));
      if (_contacts == null) return Center(child: CircularProgressIndicator());
      return ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
                title: Text(_contacts[i].displayName),
                //subtitle: Text(_contacts[i].phones[0].number)
            ),
          ));

  }
}
