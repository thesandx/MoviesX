import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/models/MovieCasts.dart';
import 'package:movie_app/models/MovieDetailModel.dart';
import 'package:movie_app/models/WatchProvider.dart';
import 'package:movie_app/widgets/MyBackButton.dart';
import 'package:movie_app/widgets/button.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants.dart';

class MovieDetails extends StatefulWidget {
  int movie_id;

  MovieDetails(this.movie_id);

  @override
  _MovieDetailsState createState() => _MovieDetailsState(movie_id);
}

class _MovieDetailsState extends State<MovieDetails> {
  final _formKey = GlobalKey<FormState>();
  int movie_id;

  _MovieDetailsState(this.movie_id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<MovieDetailModel>(
          future: CommonData.getMovieDetail(movie_id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SingleChildScrollView(child: screen(snapshot));
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController?.dispose();
  }

  Widget screen(AsyncSnapshot<MovieDetailModel> modelSnapShot) {
    if (modelSnapShot.hasData) {
      MovieDetailModel movie = modelSnapShot.data;
      Size size = MediaQuery.of(context).size;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //poster and rating
          Container(
            height: size.height * 0.4,
            child: Stack(
              children: [
                //poster
                Container(
                  height: size.height * 0.4 - 50,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(30)),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(movie.backdropPath != null
                            ? CommonData.tmdb_base_image_url +
                                "w780" +
                                movie.backdropPath
                            : CommonData.image_NA),
                      )),
                ),
                //todo  - animation
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Visibility(
                      visible: movie.voteCount > 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              bottomLeft: Radius.circular(50)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 5),
                              blurRadius: 50,
                              color: Color(0xFF12153D).withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kDefaultPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                      "assets/icons/star_fill.svg"),
                                  SizedBox(height: kDefaultPadding / 4),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: "${movie.voteAverage}/",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(text: "10\n"),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                Positioned(
                    top: 40,
                    left: 20,
                    child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: MyBackButton()))
              ],
            ),
          ),
          //title and details
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Visibility(
                        visible: (movie.tagline.length > 0),
                        child: Text(
                          movie.tagline,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      SizedBox(height: 20 / 2),
                      Row(
                        children: <Widget>[
                          Text(
                            movie.releaseDate.trim().length > 0
                                ? '${movie.releaseDate}'
                                : "",
                            style: TextStyle(color: Color(0xFF9A9BB2)),
                          ),
//                          SizedBox(width: 20),
//                          Text(
//                            movie.adult ? "18+" : "PG-13",
//                            style: TextStyle(color: Color(0xFF9A9BB2)),
//                          ),
                          SizedBox(width: 20),
                          Text(
                            movie.runtime != null
                                ? "${(movie.runtime / 60).floor()}h ${movie.runtime % 60}min"
                                : "",
                            style: TextStyle(color: Color(0xFF9A9BB2)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 64,
                  width: 64,
                  child: FlatButton(
                    onPressed: () {
                      showModalBottomSheet(
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      )),
                                  Container(
                                      height: 300,
                                      child: bottomSheet(movie_id)),
                                  Container(
                                      height: 50,
                                      child: ElevatedButton(
                                        child: Text(
                                          "Create New PlayList ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6,
                                        ),
                                        style: ButtonStyle(),
                                        onPressed: () {
                                          addPlayList();
                                        },
                                      ))
                                ],
                              ),
                            );
                          });
                    },
                    color: Color(0xFFFE6D8E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Icon(
                      Icons.add,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          //genres
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10 / 2),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movie.genres.length,
                itemBuilder: (context, index) => GenreCard(
                  genre: movie.genres[index],
                ),
              ),
            ),
          ),
          //Plot Summary
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20 / 2,
              horizontal: 20,
            ),
            child: Text(
              movie.overview.trim().length > 0 ? "Plot Summary" : "",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              movie.overview,
              style: TextStyle(
                color: Color(0xFF737599),
              ),
            ),
          ),
          //Watch on
          getWatchProvider(movie_id),
          getMovieCasts(movie_id),
          //production companies
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20 / 2,
              horizontal: 20,
            ),
            child: Text(
              movie.productionCompanies.length > 0 ? "Production" : "",
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10 / 2),
            child: SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: movie.productionCompanies.length,
                itemBuilder: (context, index) => ProductionCard(
                    production: movie.productionCompanies[index]),
              ),
            ),
          ),
          SizedBox(height: 10)
        ],
      );
    } else {
      return Text("Something went wrong");
    }
  }

  Widget CastCard({Cast cast}) {
    return Container(
      margin: EdgeInsets.only(right: kDefaultPadding),
      width: 80,
      child: Column(
        children: <Widget>[
          Container(
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(cast.profilePath != null
                    ? CommonData.tmdb_base_image_url + "w300" + cast.profilePath
                    : CommonData.image_NA),
              ),
            ),
          ),
          SizedBox(height: kDefaultPadding / 2),
          Text(
            cast.name ?? "NA",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText2,
            maxLines: 2,
          ),
          SizedBox(height: kDefaultPadding / 4),
          Text(
            cast.character ?? "NA",
            maxLines: 1,
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextLightColor),
          ),
        ],
      ),
    );
  }

  Widget GenreCard({Genres genre}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Chip(label: Text(genre.name)),
    );
  }

  Widget ProductionCard({ProductionCompanies production}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Chip(label: Text(production.name)));
  }

  Widget WatchProviderCard({Flatrate flatrate}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Chip(label: Text(flatrate.providerName)));
  }

  Widget getWatchProvider(int movie_id) {
    return FutureBuilder<WatchProvider>(
        future: CommonData.getWatchProvider(movie_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData &&
                snapshot.data.results.iN != null &&
                snapshot.data.results.iN.flatrate != null &&
                snapshot.data.results.iN.flatrate.length > 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: kDefaultPadding / 2,
                      horizontal: kDefaultPadding,
                    ),
                    child: Text(
                      "Available On",
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10 / 2),
                    child: SizedBox(
                      height: 36,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data.results.iN.flatrate.length,
                        itemBuilder: (context, index) => WatchProviderCard(
                            flatrate: snapshot.data.results.iN.flatrate[index]),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SizedBox(height: 0);
            }
          }
          return SizedBox(height: 0);
        });
  }

  Widget getMovieCasts(int movie_id) {
    return FutureBuilder<MovieCasts>(
        future: CommonData.getmovieCasts(movie_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData &&
                snapshot.data.cast != null &&
                snapshot.data.cast.length > 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: kDefaultPadding / 2,
                      horizontal: kDefaultPadding,
                    ),
                    child: Text(
                      "Casts",
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  SizedBox(height: kDefaultPadding),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (snapshot.data.cast.length > 10)
                          ? 10
                          : snapshot.data.cast.length,
                      itemBuilder: (context, index) =>
                          CastCard(cast: snapshot.data.cast[index]),
                    ),
                  )
                ],
              );
            } else {
              return SizedBox(height: 0);
            }
          }
          return SizedBox(height: 0);
        });
  }

  Widget bottomSheet(int movie_id) {
    return FutureBuilder<QuerySnapshot>(
        future: CommonData.getAllPlaylist(FirebaseAuth.instance.currentUser),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.size,
                  itemBuilder: (context, index) {
                    bool curr = false;
                    return Card(
                      child: Container(
                        padding: new EdgeInsets.all(10.0),
                        child: CheckboxListTile(
                          activeColor: Colors.pink[300],
                          dense: true,
                          title: Text(snapshot.data.docs[index].id,
                              style: Theme.of(context).textTheme.headline6),
                          value: curr,
                          onChanged: (bool val) {
                            curr = !curr;
                          },
                        ),
                      ),
                    );
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

  Widget buildNameFormField() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            onSaved: (newValue) => fullName = newValue,
            onChanged: (value) {
              if (value.isNotEmpty) {
                return null;
              }
              return null;
            },
            validator: (value) {
              if (value == null || value.isEmpty || value.trim().length == 0) {
                //addError(error: error);
                return "Name can't be empty";
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

  void addPlayList() {
    showDialog(
        context: context,
        builder: (BuildContext contex) {
          return AlertDialog(
            title: Text("Add PlayList"),
            content: buildNameFormField(),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () async {
                  //firebase call todo
                  //check duplicacy
                  if (_formKey.currentState.validate()) {
                    //no need  - not done in youtube music
                    bool isDuplicate = await CommonData.isPlaylistAlreadyExists(
                        FirebaseAuth.instance.currentUser,
                        _nameController.text.trim());

                    if (!isDuplicate) {
                      await CommonData.createPlayList(
                          FirebaseAuth.instance.currentUser,
                          _nameController.text.trim());
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: Text('CREATE'),
              ),
            ],
          );
        });
  }

//  Widget shimmerScreen(){
//    return SingleChildScrollView(
//      child: Shimmer.fromColors(
//          baseColor: Colors.grey[200],
//          highlightColor: Colors.grey[350],
//          child: screen()),
//    );
//  }
}
