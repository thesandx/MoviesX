import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/models/Results.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../../constants.dart';

class MoviePost extends StatefulWidget {
  @override
  _MoviePostState createState() => _MoviePostState();
}

class _MoviePostState extends State<MoviePost> {
  final _movieController = TextEditingController();
  final _postController = TextEditingController();
  FocusNode nodeMovie = FocusNode();
  FocusNode nodePost = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool isMovieSelected = false;
  Results currentMovie = null;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    AppBar buildAppBar() {
      return AppBar(
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
        title: Text("MoviesX",
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w800, color: Colors.black)),
      );
    }

    return Scaffold(
      appBar: buildAppBar(),
      body: ModalProgressHUD(
        inAsyncCall: CommonData.isLoading,
        child: Container(
          margin: EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _movieController,
                  decoration: InputDecoration(
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          isMovieSelected = false;
                          _movieController.text = "";
                          currentMovie = null;
                        });
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.grey,
                      ),
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
                    labelText: "Movie",
                    hintText: "Enter movie name",
                  ),
                  focusNode: nodeMovie,
                  autofocus: true,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length == 0 ||
                        currentMovie == null) {
                      //addError(error: error);
                      return "movie name can't be empty";
                    }
                    return null;
                  },
                  onChanged: (val) {
                    if (val != null &&
                        val.isNotEmpty &&
                        val.trim().length > 0) {
                      setState(() {
                        //currentMovie = null;
                        isMovieSelected = false;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Visibility(
                  visible: _movieController.text.trim().length > 0 &&
                          !isMovieSelected
                      ? true
                      : false,
                  child: FutureBuilder<List<Results>>(
                      future: CommonData.searchMovies(
                          FirebaseAuth.instance.currentUser,
                          _movieController.text),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          //movies = snapshot.data;
                          return snapshot.data.length == 0
                              ? Center(
                                  child: Text(
                                    "No results found",
                                    style: TextStyle(fontSize: 28),
                                  ),
                                )
                              : Expanded(
                                  child: Container(
                                    //height: 300,
                                    // margin: EdgeInsets.only(top: kDefaultPadding / 2,left: kDefaultPadding / 2,right: kDefaultPadding / 2),
                                    child: Scrollbar(
                                      isAlwaysShown: true,
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) =>
                                              smallMovieCard(
                                                  movie: snapshot.data[index],
                                                  context: context)),
                                    ),
                                  ),
                                );
                        }
                        return Center(child: CircularProgressIndicator());
                      }),
                ),
                Visibility(
                  visible: isMovieSelected,
                  child: TextFormField(
                    controller: _postController,
                    maxLines: 5,
                    maxLength: 200,
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
                      labelText: "Post",
                      hintText: "Share your views about this movie",
                    ),
                    focusNode: nodePost,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Visibility(
                  visible: isMovieSelected,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(30)),
//              color: Colors.blue,
                        onPressed: () {
                          addPost(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text("Post",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  smallMovieCard({Results movie, BuildContext context}) {
    return InkWell(
      child: Container(
        height: 80,
        margin: EdgeInsets.only(bottom: 5),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Colors.grey[100],
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 80,
                width: 80,
                //padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
                //margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [kDefaultShadow],
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    //i.e isi me adjust kro pura image,cover means jitna itna to cover kr do baki bahr bhi jaaye no probem
                    image: NetworkImage(movie.posterPath != null
                        ? CommonData.tmdb_base_image_url +
                            "w300" +
                            movie.posterPath
                        : CommonData.image_NA),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: kDefaultPadding / 2,
                      horizontal: kDefaultPadding / 4),
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.black,
                              letterSpacing: 0.5),
                          children: <TextSpan>[
                        TextSpan(
                          text: movie.title + " - ",
                          //overflow: TextOverflow.ellipsis //no need of it,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: movie.releaseDate.split("-")[0] + "\n",
                          //overflow: TextOverflow.ellipsis //no need of it,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                      ])),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        setState(() {
          isMovieSelected = true;
          currentMovie = movie;
          _movieController.text = movie.title;
//          FocusScopeNode currentFocus = FocusScope.of(context);
//          if (!currentFocus.hasPrimaryFocus) {
//            currentFocus.unfocus();
//          };
          FocusScope.of(context).requestFocus(nodePost);
        });
      },
    );
  }

  addPost(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      setState(() {
        CommonData.isLoading = true;
      });
      String post =
          _postController.text != null ? _postController.text.trim() : "";
      Results movie = currentMovie;
      bool val = await CommonData.addPost(post, movie);
      if (val) {
        //show snackbar and navigate;
        setState(() {
          CommonData.isLoading = false;
        });

        showSnackbar("Your Post was sent");
        Navigator.of(context).pop();
      } else {
        setState(() {
          CommonData.isLoading = false;
          ;
        });
        //show error
        showSnackbar("Something went wrong");
      }
    }
  }

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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _movieController?.dispose();
    _postController?.dispose();
    nodeMovie?.dispose();
    nodePost.dispose();
  }
}
