import 'package:flutter/material.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/models/MovieDetailModel.dart';
import 'package:shimmer/shimmer.dart';

class MovieDetails extends StatefulWidget {
  int movie_id;

  MovieDetails(this.movie_id);

  @override
  _MovieDetailsState createState() => _MovieDetailsState(movie_id);
}

class _MovieDetailsState extends State<MovieDetails> {
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
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: size.width * 0.9,
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
                      child: Row(),
                    ))
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
                            '${movie.releaseDate.split("-")[0]}',
                            style: TextStyle(color: Color(0xFF9A9BB2)),
                          ),
                          SizedBox(width: 20),
                          Text(
                            movie.adult ? "18+" : "PG-13",
                            style: TextStyle(color: Color(0xFF9A9BB2)),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "${(movie.runtime / 60).floor()}h ${movie.runtime % 60}min",
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
                    onPressed: () {},
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
              "Plot Summary",
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
          //production companies
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 20 / 2,
              horizontal: 20,
            ),
            child: Text(
              "Production",
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
                  production: movie.productionCompanies[index]
                ),
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

  Widget GenreCard({Genres genre}) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Chip(label: Text(genre.name)),
    );
    
  }

  Widget ProductionCard({ProductionCompanies production}) {
    return  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Chip(label: Text(production.name))
    );
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
