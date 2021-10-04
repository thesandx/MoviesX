import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Services/CommonData.dart';

class MyBottomSheet {
  Future<dynamic> showBottomSheet(
      BuildContext context, GlobalKey<FormState> _formKey, int movie_id) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (builder) {
          return Container(
            height: 400,
            child: Column(
              children: [
                Container(
                    height: 30,
                    child: Text(
                      "PlayList",
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline5,
                    )),
                Container(height: 300, child: bottomSheet(movie_id)),
                Container(
                    height: 50,
                    child: ElevatedButton(
                      child: Text(
                        "Create New PlayList ",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      style: ButtonStyle(),
                      onPressed: () {
                        addPlayList(context, _formKey);
                      },
                    ))
              ],
            ),
          );
        });
  }

  Widget bottomSheet(int movie_id) {
    return FutureBuilder<List<Map>>(
        future: CommonData.getAllPlaylist(
            FirebaseAuth.instance.currentUser, movie_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    bool curr = snapshot.data[index]["is_included"];
                    return StatefulBuilder(builder:
                        (BuildContext context, StateSetter innerSetState) {
                      return Card(
                        child: Container(
                          padding: new EdgeInsets.all(10.0),
                          child: CheckboxListTile(
                            activeColor: Colors.pink[300],
                            dense: true,
                            title: Text(snapshot.data[index]["name"],
                                style: Theme.of(context).textTheme.headline6),
                            value: curr,
                            onChanged: (bool val) async {
                              print(val);
                              innerSetState(() {
                                curr = !curr;
                              });
                              await CommonData.addMovieInPlayList(
                                  FirebaseAuth.instance.currentUser,
                                  snapshot.data[index]["name"],
                                  movie_id,
                                  val);
                            },
                          ),
                        ),
                      );
                    });
                  });
            } else {
              return Center(child: Text("No item found"));
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  final _nameController = TextEditingController();
  String fullName;
  bool showError = false;
  String playListName = "";

  Widget buildNameFormField(GlobalKey<FormState> _formKey) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            maxLength: 20,
            controller: _nameController,
            onSaved: (newValue) => fullName = newValue,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              if (value.isNotEmpty && value != playListName) {
                showError = false;
                _formKey.currentState.validate();
                return null;
              }
              return null;
            },
            validator: (value) {
              if (value == null || value.isEmpty || value.trim().length == 0) {
                //addError(error: error);
                showError = false;
                return "Name can't be empty";
              } else if (showError) {
                //showError = false;
                return "playList already exists";
              }
              return null;
            },
            decoration: InputDecoration(
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
              labelText: "Name",
              hintText: "Enter playList Name",
              // floatingLabelBehavior: FloatingLabelBehavior.always
            ),
          ),
          Visibility(
            visible: false,
            child: Text(
              "playList already exists",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void addPlayList(BuildContext context, GlobalKey<FormState> _formKey) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add PlayList"),
            content: buildNameFormField(_formKey),
            actions: [
              TextButton(
                onPressed: () {
                  showError = false;
                  Navigator.of(context).pop();
                },
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  //firebase call todo
                  //check duplicacy
                  if (_formKey.currentState.validate()) {
                    bool isDuplicate = await CommonData.isPlaylistAlreadyExists(
                        FirebaseAuth.instance.currentUser,
                        _nameController.text.trim());

                    if (!isDuplicate) {
                      await CommonData.createPlayList(
                          FirebaseAuth.instance.currentUser,
                          _nameController.text.trim());
                      showError = false;
                      Navigator.of(context).pop();
                    } else {
                      showError = true;
                      playListName = _nameController.text.trim();
                      _formKey.currentState.validate();
                    }
                  }
                },
                child: Text('CREATE'),
              ),
            ],
          );
        });
  }
}
