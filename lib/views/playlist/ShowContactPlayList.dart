import 'package:flutter/material.dart';
import 'package:movie_app/views/Social/Profile.dart';

import '../../constants.dart';

class ShowContactPlayList extends StatefulWidget {
  String contactName;
  String user_id;
   ShowContactPlayList(this.contactName,this.user_id);

  @override
  State<ShowContactPlayList> createState() => _ShowContactPlayListState(contactName,user_id);
}

class _ShowContactPlayListState extends State<ShowContactPlayList> {
  String contactName;
  String user_id;
  _ShowContactPlayListState(this.contactName,this.user_id);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xfff3f5f7),
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.only(left: kDefaultPadding),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(contactName,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w800, color: Colors.black)),
      ),
      body: ProfilePage(user_id: user_id)
    );
  }
}
