import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:movie_app/Services/CommonData.dart';
import 'package:movie_app/models/Results.dart';
import 'package:movie_app/views/movie_detail/MovieDetails.dart';
import '../constants.dart';

class MovieSearch extends SearchDelegate{
  final _logger = Logger('com.thesandx.movie_app');
  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    //i.e cross wala icon
    return[
      IconButton(icon: Icon(Icons.clear), onPressed:( ){
        query = "";
      })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    //i.e back button de do
    IconButton(icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
      progress: transitionAnimation,
    ), onPressed:(){
      Navigator.of(context).pop();

    });
  }

  @override
  Widget buildResults(BuildContext context) {
    //show when select the search and press enter
    final String  val= query.isEmpty ? "":query.trim();
    if(val==null || val.isEmpty|| val.length<1){
      return Text("No results found");
    }
    if(query[0]=="@"){
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return
            searchUsers(val);
          }
      );
    }
    return searchResult(val);

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    //show while searching
    final String  val= query.isEmpty ? "":query.trim();
    if(val==null || val.isEmpty|| val.length<1){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter movie name",
              style: TextStyle(
                  fontSize: 28
              ),
            ),
        Text("use @ to search users",
          style: TextStyle(
              fontSize: 18
          ),
        )
          ],
        ),
      );
    }

    if(query[0]=="@"){
      return searchUsers(val);
    }

    return searchResult(val);

  }

  Widget searchUsers(String val){
    return FutureBuilder<List<dynamic>>(
        future: CommonData.searchUsers(FirebaseAuth.instance.currentUser,val),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.done){

            return snapshot.data.length==0 ? Center(
              child: Text("No results found",
                style: TextStyle(
                    fontSize: 28
                ),
              ),
            ) :
            Container(
              margin: EdgeInsets.only(top: kDefaultPadding / 2,left: kDefaultPadding / 2,right: kDefaultPadding / 2),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) =>
                      smallUserCard(user: snapshot.data[index],context: context)),
            );

          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget searchResult(String val){
    return FutureBuilder<List<Results>>(
        future: CommonData.searchMovies(FirebaseAuth.instance.currentUser,val),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return snapshot.data.length==0 ? Center(
              child: Text("No results found",
                style: TextStyle(
                    fontSize: 28
                ),
              ),
            ) :
            Container(
              margin: EdgeInsets.only(top: kDefaultPadding / 2,left: kDefaultPadding / 2,right: kDefaultPadding / 2),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) =>
                      smallMovieCard(movie: snapshot.data[index],context: context)),
            );

          }
          return Center(child: CircularProgressIndicator());
        });
  }


  Widget smallUserCard({dynamic user,BuildContext context}) {
    print("user ka detail $user");
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)),
      color:Colors.grey[100],
      child: ListTile(
        leading: Icon(Icons.account_circle,
          size:50
        ),
        title: Text(user['name']?? "NA"),
        subtitle: Text(user['user_name']?? "NA"),
        trailing: Visibility(
          visible: FirebaseAuth.instance.currentUser.uid!=user['user_id'],
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(
                '/users/${FirebaseAuth.instance.currentUser.uid}/following')
                .where("user_id", isEqualTo: user['user_id'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print("error aaya hai");
              }
              if (snapshot.connectionState == ConnectionState.active) {
                bool val = snapshot.data.docs.length > 0
                    ? snapshot.data.docs[0]['liked'] ?? false
                    : false;
                return TextButton(
                  onPressed: (){
                    addFollowing(user['user_id'],!val );
                  },
                  child: Text("${val?"Following":"Follow"}"),
                );
              }
              else if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              return TextButton(
                onPressed: (){
                  addFollowing(user['user_id'],true );
                },
                child: Text("Follow"),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget smallMovieCard({Results movie,BuildContext context}) {
    return Container(
      height: 200,
      margin: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: ()=> Navigator.push(context,  MaterialPageRoute(builder: (context) => MovieDetails(movie.id))),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)),
          color:Colors.grey[100],
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    //padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
                    //margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [kDefaultShadow],
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        //i.e isi me adjust kro pura image,cover means jitna itna to cover kr do baki bahr bhi jaaye no probem
                        image:NetworkImage(movie.posterPath != null
                            ? CommonData.tmdb_base_image_url + "w400" + movie.posterPath
                            : CommonData.image_NA),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child:  StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection(
                            '/users/${FirebaseAuth.instance.currentUser.uid}/movies').where("movie_id",isEqualTo: movie.id).
                        snapshots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasError){
                            print("error aaya hai ${movie.id}");
                          }
                          if (snapshot.connectionState == ConnectionState.active) {
                            //print(snapshot.data.toString() + " ${movie.id}");
                            bool val = snapshot.data.docs.length > 0 ? snapshot.data.docs[0]['liked']?? false:false;
                            return InkWell(
                              child: Icon(Icons.favorite,
                                  size: 35,
                                  color: val
                                      ? Colors.red.withOpacity(1.0)
                                      : Colors.white.withOpacity(0.7)),
                              onTap: () {
                                //print("Movie id ${movie.id} ,abhi hai  - ${CommonData.likedMovies[movie.id]} ,krenge - ${movie.id} ${CommonData.likedMovies[movie.id]?? false}");
                                addMovie(movie.id, val ?? false,movie.posterPath);
                              },
                            );
                          }
                          else  if(snapshot.connectionState == ConnectionState.waiting){
                            return Center(child: CircularProgressIndicator());
                          }
                          else{
                            return InkWell(
                              child: Icon(Icons.favorite,
                                  size: 35,
                                  color:Colors.white.withOpacity(0.7)),
                              onTap: () {
                                addMovie(movie.id, false,movie.posterPath);
                              },
                            );
                          }
                        }),
                  )
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: kDefaultPadding / 2, horizontal: kDefaultPadding/4),
                  child: RichText(
                    text: TextSpan(
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.black,
                    letterSpacing: 0.5
                  ),
                        children: <TextSpan>[

                          TextSpan(
                           text: movie.title+"\n\n",
                            //overflow: TextOverflow.ellipsis //no need of it,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: "Year: "+movie.releaseDate.split("-")[0]+"\n",
                            //overflow: TextOverflow.ellipsis //no need of it,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(fontWeight: FontWeight.w800),
                          ),

                        ]
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addMovie(int movie_id, bool isLiked,String poster) async {
    _logger.info("movie liked $movie_id ${!isLiked}");
    await CommonData.addLikedMovie(
        FirebaseAuth.instance.currentUser, movie_id, !isLiked,poster);

  }

  void addFollowing(String followingId,bool isFollow) async {
    if (FirebaseAuth.instance.currentUser.uid == followingId) {
      return;
    }
    CommonData.addFollowing(
        FirebaseAuth.instance.currentUser.uid, followingId, isFollow);
  }


}