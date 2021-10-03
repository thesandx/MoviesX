import 'package:flutter/material.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/models/MovieDetailModel.dart';
import 'package:movie_app/views/movie_detail/MovieDetails.dart';
import 'package:movie_app/widgets/MyBottomSheet.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants.dart';

class ShowPlayList extends StatefulWidget {
  String playListName;
  List<dynamic> movieList;

  ShowPlayList(this.playListName, this.movieList);

  @override
  _ShowPlayListState createState() =>
      _ShowPlayListState(playListName, movieList);
}

class _ShowPlayListState extends State<ShowPlayList> {
  String playListName;
  List<dynamic> movieList;
  static final _formKey = GlobalKey<FormState>();

  _ShowPlayListState(this.playListName, this.movieList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(playListName,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w800, color: Colors.black)),
      ),
      body: movieGrid(),
    );
  }

  Widget movieGrid() {
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      crossAxisCount: 2,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      childAspectRatio: 5 / 6,
      children: movieList.map((var movie_id) {
        return InkWell(
          onLongPress: () =>
              MyBottomSheet().showBottomSheet(context, _formKey, movie_id),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => MovieDetails(movie_id))),
          child: buildPictureCard(movie_id),
        );
      }).toList(),
    );
  }

  Widget buildPictureCard(int movie_id) {
    //futureBuilder
    return FutureBuilder<MovieDetailModel>(
        future: CommonData.getMovieDetail(movie_id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return pictureCard(snapshot.data.posterPath != null
                ? CommonData.tmdb_base_image_url +
                    "w300" +
                    snapshot.data.posterPath
                : CommonData.image_NA);
          } else {
            return shimmerScreen();
          }
        });
  }

  Widget pictureCard(String url) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(url),
            )),
      ),
    );
  }

  Widget shimmerScreen() {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
          baseColor: Colors.grey[200],
          highlightColor: Colors.grey[350],
          child: Center(child: CircularProgressIndicator())),
    );
  }
}
