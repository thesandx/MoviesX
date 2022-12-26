import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/MovieCasts.dart';
import 'package:movie_app/models/MovieDetailModel.dart';
import 'package:movie_app/models/Results.dart';
import 'package:movie_app/models/Show.dart';
import 'package:movie_app/models/TrendingMovies.dart';
import 'package:movie_app/models/TrendingShows.dart';
import 'package:movie_app/models/WatchProvider.dart';

class CommonData {
  static AsyncSnapshot<QuerySnapshot> savedSnapshot;
  static AsyncSnapshot<QuerySnapshot> savedPlayListSnapshot;

  static bool isLoading = false;
  static String currentUserId = FirebaseAuth.instance.currentUser.uid;

  static String tmdb_api_key;

  static String image_NA =
      "https://1.bp.blogspot.com/-JXjPS9M7MMU/XX39ZP97p4I/AAAAAAAAABE/VQYxrz_roLcXRf5m1nyxTYIxFh7KGow7wCPcBGAYYCw/s1600/df1.jpg";

  static String tmdb_base_url = "https://api.themoviedb.org/3/";
  static String tmdb_base_image_url = "https://image.tmdb.org/t/p/";
  static String language = "&language=en-US"; //hi-IN,en-US,en-IN
  static String region = "&region=US"; //in or us in caps

  static List<Results> trendingMovies = [];
  static List<Results> nowPlayingMovies = [];
  static List<Results> upcomingMovies = [];
  static List<Results> popularMovies = [];
  static List<Show> trendingTv = [];
  static List<String> followingUsers = [];

  static Map<int, bool> likedMovies = new Map();

  //static Map<int, bool> allMovies = new Map();

  static Future<void> findMovieData(User user) async {
    trendingMovies = await findTrendingMovies();
    //trendingTv = await findTrendingShows();
    nowPlayingMovies = await findNowPlayingMovies();
    upcomingMovies = await findUpcomingMovies();
    popularMovies = await findPopularMovies();
    //add all new movie id to peopple
    //await addNewMovieinDB(user);
    return;
  }


//  static Future<void> fetchTimeline(User user) async{
//    QuerySnapshot posts = await FirebaseFirestore.instance.collection('posts').orderBy("date",descending: true).limit(100).get();
//    WriteBatch batch = FirebaseFirestore.instance.batch();
//    List<int> moviesId = [];
//    CollectionReference movies = FirebaseFirestore.instance.collection(
//        '/users/' + user.uid + '/movies');
//
//    posts.docs.forEach((doc) {
//      if(!allMovies.containsKey(doc["movie_id"])){
//        moviesId.add(doc["movie_id"]);
//      }
//    });
//    print("naya movie ka length ${moviesId.length}");
//    for (int i in moviesId) {
//      // print("movie id is  ${i}");
//      allMovies[i] = false;
//      DocumentReference documentReference = movies.doc(i.toString());
//      batch.set(documentReference, {
//        "liked": false,
//        "movie_id": i
//      });
//    }
//    await batch.commit();
//    return;
//  }

  static dynamic returnJson(Results movie,String post){
    return {
      "user_id":FirebaseAuth.instance.currentUser.uid,
      "movie_id":movie.id,
      "post":post,
      "title":movie.title??"NA",
      "overview":movie.overview??"NA",
      "releaseDate":movie.releaseDate,
      "backdropPath":movie.backdropPath,
      "genreIds":movie.genreIds,
      "posterPath":movie.posterPath,
      "date":Timestamp.now(),
      "likes":0
    };
  }

  static Future<bool> addPost(String post,Results movie) async{
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    if(movie!=null){
      try {
        await posts.add(returnJson(movie,post));
        return true;
      } catch (e) {
        return false;
      }
    }
    else{
      return false;
    }
  }

//  static Future<Map<int, bool>> getAllMovies(CollectionReference movies) async {
//    Map<int, bool> map = new Map();
//    //get already stored movie
//    //ToDo every time such heavy read will full the quota,either local persists or commonData
//    QuerySnapshot querySnapshot = await movies.get();
//    print("pura movie fetch mar rhe, Heavy read");
//    print("lentgh of total movies is ${querySnapshot.size}");
//    querySnapshot.docs.forEach((doc) {
//      //print("Db ka movie id ${doc['movie_id']}");
//      map[doc['movie_id']] = doc['liked'];
//    });
//    allMovies.addAll(map);
//    return map;
//  }

  static Future<List<dynamic>> getAllUsers() async {
    QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore.instance
        .collection('users').get();
    //check if doc exists
    List<dynamic> list = [];
    print("size is ${users.docs.length}");
    users.docs.forEach((doc) {
      // print(doc.data());
      if(doc['mobile']!=null) {
        list.add({
          //'name': doc['name'],
          //'user_name': doc['user_name'],
          'user_id': doc.id,
          'mobile': doc['mobile'],
        });
      }
    });
    return list;
  }


  static Future<List<dynamic>> searchUsers(User user,String query) async{
    query = query.substring(1).toLowerCase();
    if(query==null ||query.isEmpty || query.trim().length==0){
      return [];
    }

    QuerySnapshot<Map<String, dynamic>> users  = await FirebaseFirestore.instance.collection('users').get();
    //check if doc exists
    List<dynamic>  list = [];
    users.docs.forEach((doc) {
      // print(doc.data());
      if(doc.data()['name'].toString().toLowerCase().contains(query) || doc.data()['user_name'].toString().toLowerCase().contains(query)){
        list.add({
          'name':doc['name'],
          'user_name':doc['user_name'],
          'user_id':doc.id
        });
      };
    });
    return list;

//    DocumentSnapshot documentSnapshot = await users.doc(
//        FirebaseAuth.instance.currentUser.uid).get();
//    if (documentSnapshot.exists) {
//      print(documentSnapshot.data());
//      return documentSnapshot.data();
//    }
//    else {
//      return null;
//    }


  }

  static Future<List<Results>> searchMovies(User user, String query) async {
    if(query==null ||query.isEmpty || query.trim().length==0){
      return null;
    }
    var url = Uri.parse(
        tmdb_base_url + 'search/movie?api_key=' + tmdb_api_key + language +
            "&query=${query}&include_adult=false");
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    if(response.statusCode>200){
      return null;
    }
    var data = response.body;
    var myjson = jsonDecode(data);

    List<Results> res = TrendingMovies
        .fromJson(myjson)
        .results;

    //enter new values in db
//
//    CollectionReference movies = FirebaseFirestore.instance.collection(
//        '/users/' + user.uid + '/movies');
//
//    WriteBatch batch = FirebaseFirestore.instance.batch();
//    Map<int, bool> map = allMovies.length == 0
//        ? await getAllMovies(movies)
//        : allMovies;
//    List<int> moviesId = [];
//    for (Results r in res) {
//      if (!map.containsKey(r.id)) {
//        moviesId.add(r.id);
//      }
//    }
//
//    print("naya movie ka length ${moviesId.length}");
//    for (int i in moviesId) {
//      // print("movie id is  ${i}");
//      allMovies[i] = false;
//      DocumentReference documentReference = movies.doc(i.toString());
//      batch.set(documentReference, {
//        "liked": false,
//        "movie_id": i
//      });
//    }


    //await batch.commit();
    return res;
  }

  static Future<void> fetchFollwing(User user) async{
    QuerySnapshot<Map<String, dynamic>> following = await FirebaseFirestore.instance
        .collection('/users/' + user.uid + '/following')
        .where('liked', isEqualTo: true)
        .get();

    List<String> res = [];
    following.docs.forEach((doc) {
      res.add(doc['user_id']);
      print("${doc['user_id']}");
    });
    followingUsers.clear();
    followingUsers.addAll(res);
    followingUsers.add(user.uid);
    return;
  }

  static Future<bool> addFollowing(String followerId,String followingId,bool liked) async{
    try {
      CollectionReference following = FirebaseFirestore.instance.collection(
          '/users/' + followerId + '/following');
      DocumentSnapshot documentSnapshot = await following.doc(followingId).get();
      if (documentSnapshot.exists) {
        print(documentSnapshot.data());
        print("detail exists");
        await following.doc(followingId).update({
          "liked": liked,
          "user_id": followingId
        });
      }
      else {
        //create moviedid
        //add movie
        await following.doc(followingId).set({
          "liked": liked,
          "user_id": followingId
        });
        print("following added successfully " + followingId);
      }


      //addFollower
      CollectionReference follower = FirebaseFirestore.instance.collection(
          '/users/' + followingId + '/follower');


      DocumentSnapshot documentSnapshot1 = await follower.doc(followerId).get();
      if (documentSnapshot1.exists) {
        print(documentSnapshot1.data());
        print("detail exists");
        await follower.doc(followerId).update({
          "liked": liked,
          "user_id": followerId
        });
        return true;
      }
      else {
        //create moviedid
        //add movie
        await follower.doc(followerId).set({
          "liked": liked,
          "user_id": followerId
        });
        print("follower added successfully " + followerId);
        if(liked){
          followingUsers.add(followingId);
        }
        else{
          followingUsers.remove(followingId);
        }

        return true;
      }
    } catch (e) {
      // TODO
      print("error aa gya");
      return false;
    }
  }

  static Future<List<Results>> findPopularMovies() async {
    var url = Uri.parse(
        tmdb_base_url + 'movie/popular?api_key=' + tmdb_api_key + language +
            region);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    TrendingMovies trendingMovies = TrendingMovies.fromJson(myjson);
    print(trendingMovies.results.length);
    return trendingMovies.results;
  }


  static Future<List<Results>> findUpcomingMovies() async {
    var url = Uri.parse(
        tmdb_base_url + 'movie/upcoming?api_key=' + tmdb_api_key + language +
            region);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    TrendingMovies trendingMovies = TrendingMovies.fromJson(myjson);
    print(trendingMovies.results.length);
    return trendingMovies.results;
  }

  static Future<List<Results>> findNowPlayingMovies() async {
    var url = Uri.parse(
        tmdb_base_url + 'movie/now_playing?api_key=' + tmdb_api_key + language +
            region);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    TrendingMovies trendingMovies = TrendingMovies.fromJson(myjson);
    print(trendingMovies.results.length);
    return trendingMovies.results;
  }

  static Future<List<Results>> findTrendingMovies() async {
    var url = Uri.parse(
        tmdb_base_url + 'trending/movie/day?api_key=' + tmdb_api_key);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    TrendingMovies trendingMovies = TrendingMovies.fromJson(myjson);
    print(trendingMovies.results.length);
    return trendingMovies.results;
  }

  static Future<WatchProvider> getWatchProvider(int movie_id) async{
    var url = Uri.parse(
        tmdb_base_url + 'movie/$movie_id/watch/providers?api_key=' + tmdb_api_key);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    WatchProvider watchProvider = WatchProvider.fromJson(myjson);
    return watchProvider;
  }

  static Future<MovieCasts> getmovieCasts(int movie_id) async{
    var url = Uri.parse(
        tmdb_base_url + 'movie/$movie_id/credits?api_key=' + tmdb_api_key);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    MovieCasts movieCasts= MovieCasts.fromJson(myjson);
    return movieCasts;
  }


  static Future<MovieDetailModel> getMovieDetail (int movie_id) async {
    print("movie id is $movie_id");
    var url = Uri.parse(
        tmdb_base_url + 'movie/$movie_id?api_key=' + tmdb_api_key);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    MovieDetailModel detailModel = MovieDetailModel.fromJson(myjson);
    return detailModel;
  }


  static Future<List<Show>> findTrendingShows() async {
    var url = Uri.parse(
        tmdb_base_url + 'trending/tv/day?api_key=' + tmdb_api_key);
    print(url);
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;


    var myjson = jsonDecode(data);
    //print(myjson);
    TrendingShows trendingShows = TrendingShows.fromJson(myjson);
    print(trendingShows.results.length);
    return trendingShows.results;
  }

  static Future<bool> retriveAPIKey() async {
    CollectionReference tmdb = FirebaseFirestore.instance.collection('TMDB');

    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await tmdb.doc("tmdb_api_key").get();
    if (documentSnapshot.exists) {
      print("api_key mil gya");
      //print(documentSnapshot.data());
      tmdb_api_key = documentSnapshot.data()['v3_auth'];


      return true;
    }
    else {
      return false;
    }
  }

  static Future<dynamic> fetchProfileData() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if doc exists
    DocumentSnapshot documentSnapshot = await users.doc(
        FirebaseAuth.instance.currentUser.uid).get();
    if (documentSnapshot.exists) {
      print(documentSnapshot.data());
      return documentSnapshot.data();
    }
    else {
      return null;
    }
  }

  static Future<bool> isUsernameAvailable(String username) async {
    final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance
        .collection('users')
        .where('user_name', isEqualTo: username)
        .limit(1)
        .get();
    final List<QueryDocumentSnapshot> documents = result.docs;
    return documents.length == 1;
  }


  static Future<void> getLikedMovies(User user) async {
    likedMovies.clear();
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('/users/' + user.uid + '/movies')
        .get();

    querySnapshot.docs.forEach((doc) {
      likedMovies[doc["movie_id"]] = doc["liked"];
    });
  }

//  static Future<void> addNewMovieinDB(User user) async {
//    WriteBatch batch = FirebaseFirestore.instance.batch();
//    //get already stored movie
//    CollectionReference movies = FirebaseFirestore.instance.collection(
//        '/users/' + user.uid + '/movies');
//    Map<int, bool> map = allMovies.length == 0
//        ? await getAllMovies(movies)
//        : allMovies;
//
//
//    List<int> moviesId = new List<int>();
//    for (Results r in trendingMovies) {
//      if (!map.containsKey(r.id)) {
//        moviesId.add(r.id);
//      }
//    }
//
//    for (Results r in nowPlayingMovies) {
//      if (!map.containsKey(r.id)) {
//        moviesId.add(r.id);
//      }
//    }
//
//    for (Results r in upcomingMovies) {
//      if (!map.containsKey(r.id)) {
//        moviesId.add(r.id);
//      }
//    }
//
//    for (Results r in popularMovies) {
//      if (!map.containsKey(r.id)) {
//        moviesId.add(r.id);
//      }
//    }
//
//
//    print("naya movie ka length ${moviesId.length}");
//    for (int i in moviesId) {
//      // print("movie id is  ${i}");
//      allMovies[i] = false;
//      DocumentReference documentReference = movies.doc(i.toString());
//      batch.set(documentReference, {
//        "liked": false,
//        "movie_id": i
//      });
//    }
//    return await batch.commit();
//  }

  static Future<bool> increaseLikesCount(String docId,bool increase) async{
    CollectionReference posts = await FirebaseFirestore.instance.collection(
        'posts');
    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await posts.doc(docId).get();

    if (documentSnapshot.exists) {
      await posts.doc(docId).update({
        "likes": increase
            ? documentSnapshot.data()['likes'] + 1
            : documentSnapshot.data()['likes'] > 0
                ? documentSnapshot.data()['likes'] - 1
                : documentSnapshot.data()['likes'],
      }).then((value) {
        print("likes increased");
        return true;
      }).catchError((error) {
        print("Failed to add likes: $error");
        return false;
      });
    }
  }

  static Future<List<Map>> getAllPlaylist(User user, int movie_id) async {
    List list = <Map>[];
    CollectionReference playlist = FirebaseFirestore.instance
        .collection('/users/' + user.uid + '/playlist');
    //i.e get list of documents
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await playlist.orderBy("name").get();

    querySnapshot.docs.forEach((doc) {
      var map = {};
      map["name"] = doc.id;
      bool curr = false;
      for (int i in doc["movies_id"]) {
        if (i == movie_id) {
          curr = true;
          break;
        }
      }
      map["is_included"] = curr;
      list.add(map);
    });

    return list;
    //ref-  https://firebase.flutter.dev/docs/firestore/usage#document--query-snapshots

  }

  static Future<bool> createPlayList(User user,String playListName) async{
    CollectionReference playlist = FirebaseFirestore.instance.collection(
        '/users/' + user.uid + '/playlist');

    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await playlist.doc(playListName)
        .get();

    if (documentSnapshot.exists) {
      return true;
    }
    else{
      await playlist.doc(playListName).set({
        "name": playListName,
        "movies_id": FieldValue.arrayUnion([])
      }).then((value) async {
        print("playlist $playListName added successfully");
        //await getLikedMovies(user);
        // allMovies[movie_id] = liked;
        return true;
      }).catchError((error) {
        print("Failed to add playlist: $error");
        return false;
      });
    }
  }


  static Future<bool> isPlaylistAlreadyExists(User user,String playListName) async{
    CollectionReference playlist = FirebaseFirestore.instance.collection(
        '/users/' + user.uid + '/playlist');

    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await playlist.doc(playListName)
        .get();

    if (documentSnapshot.exists) {
      return true;
    }
    else{
      return false;
    }
  }

  static Future<bool> addDefaultPlaylist(User user) async{
    CollectionReference playlist = FirebaseFirestore.instance
        .collection('/users/' + user.uid + '/playlist');

    //check if watch later exists
    DocumentSnapshot<Map<String,dynamic>> watchLaterDoc = await playlist.doc("watch later").get();
    DocumentSnapshot<Map<String,dynamic>> watchedDoc = await playlist.doc("watched").get();

    if (watchLaterDoc.exists) {
      //check if this movie is here or not
      print("playlist already exists");
    } else {
      //create watch later playlist
      await playlist.doc("watch later").set({
        "name": "watch later",
        "movies_id": FieldValue.arrayUnion([])
      }).then((value) async {
        print("playlist added successfully");
        //await getLikedMovies(user);
        // allMovies[movie_id] = liked;
      }).catchError((error) {
        print("Failed to add playlist: $error");
      });
    }

    if (watchedDoc.exists) {
      //check if this movie is here or not
      print("playlist2 already exists");
    } else {
      //create watch later playlist
      await playlist.doc("watched").set({
        "name": "watched",
        "movies_id": FieldValue.arrayUnion([])
      }).then((value) async {
        print("playlist2 added successfully");
        //await getLikedMovies(user);
        // allMovies[movie_id] = liked;
      }).catchError((error) {
        print("Failed to add playlist: $error");
      });
    }
  }

  static Future<bool> deletePlayList(String playListName, User user) async {
    CollectionReference playListCollection = FirebaseFirestore.instance
        .collection('/users/' + user.uid + '/playlist');
    await playListCollection.doc(playListName).delete();
    return true;
  }

  static Future<bool> addMovieInPlayList(User user, String playListName,
      int movie_id, bool isAdd) async {
    CollectionReference playListCollection = FirebaseFirestore.instance
        .collection('/users/' + user.uid + '/playlist');
    //check if movieid exists
    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await playListCollection
        .doc(playListName)
        .get(); //or we can use collection with where
    if (documentSnapshot.exists) {
      print("detail exists");
      // https: //firebase.google.com/docs/firestore/manage-data/add-data#update_elements_in_an_array
      print(documentSnapshot.data());
      if (!isAdd) {
        //i.e delete this document
        await playListCollection.doc(playListName).update({
          "movies_id": FieldValue.arrayRemove([movie_id])
        });
        return true;
      }
      else {
        await playListCollection.doc(playListName).update({
          "movies_id": FieldValue.arrayUnion([movie_id])
        });
        return true;
      }
    }
//    else if(isAdd){
//      //create moviedid
//      //add movie
//      await playListCollection.doc(movie_id.toString()).set({
//        "movie_id": movie_id,
//      }).then((value) async {
//        print("Movie added successfully to $playListName " + movie_id.toString());
//        return true;
//      }).catchError((error) {
//        print("Failed to add movie: $error");
//        return false;
//      });
//    }
    else {
      return true;
    }
  }

  static Future<bool> addLikedMovie(User user, int movie_id, bool liked,
      String poster) async {
    CollectionReference movies = FirebaseFirestore.instance.collection(
        '/users/' + user.uid + '/movies');
    //check if movieid exists
    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await movies.doc(movie_id.toString())
        .get(); //or we can use collection with where
    if (documentSnapshot.exists) {
      print(documentSnapshot.data());
      print("detail exists");
      await movies.doc(movie_id.toString()).update({
        "liked": liked,
        "movie_id": movie_id,
        "poster":poster
      }).then((value) async {
        print("Movie added successfully " + movie_id.toString());
        //await getLikedMovies(user);
        // allMovies[movie_id] = liked;
        return true;
      }).catchError((error) {
        print("Failed to add movie: $error");
        return false;
      });
    }
    else {
      //create moviedid
      //add movie
      await movies.doc(movie_id.toString()).set({
        "liked": liked,
        "movie_id": movie_id,
        "poster":poster
      }).then((value) async {
        print("Movie added successfully " + movie_id.toString());
        //await getLikedMovies(user);
        //allMovies[movie_id] = liked;
        return true;
      }).catchError((error) {
        print("Failed to add movie: $error");
        return false;
      });
    }
  }

  static Future<bool> checkIfUserDetailExists(User user) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if doc exists
    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await users.doc(user.uid).get();
    if (documentSnapshot.exists) {
      print(documentSnapshot.data());
      if (documentSnapshot.data()['user_name'] == null ||
          documentSnapshot.data()['user_name']
              .toString()
              .length < 1) {
        print("detail not exists");
        return false;
      }
      else {
        print("detail exists");
        return true;
      }
    }
    else {
      return false;
    }
  }

  static Future<bool> checkIfUserExists(User user) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if doc exists
    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await users.doc(user.uid).get();
    if (documentSnapshot.exists) {
      print("user exists");
      return true;
    }
    else {
      print("user does not exists");
      return false;
    }
  }


  static Future<bool> createUser(User user) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    //check if user exists
    DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await users.doc(user.uid).get();
    if (!documentSnapshot.exists) {
      //if not then add the doc

      try{
        await users
            .doc(user.uid)
            .set({
          "mobile": user.phoneNumber
        });
        print("user added in db");
        return true;
      }
      catch(error){
        print("Error:failed to add user"+error.toString() ??"");
        return false;
      }
    }
    else {
      print("user already hai");
      return true;
      //check if
    }
  }

  static Future<bool> addUserData(String name, String username) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    if (user == null) {
      print("Error : user null hai");
    }


    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc(user.uid).update({
      "name": name,
      "user_name": username
    }).then((value) {
      print("detail added ");
      return true;
    }).
    catchError((error) {
      print("Failed to add user: $error");
      return false;
    });
  }

}