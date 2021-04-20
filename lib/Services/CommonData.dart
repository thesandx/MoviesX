import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/models/Results.dart';
import 'package:movie_app/models/Show.dart';
import 'package:movie_app/models/TrendingMovies.dart';
import 'package:http/http.dart' as http;
import 'package:movie_app/models/TrendingShows.dart';

class CommonData {

  static bool isLoading = false;

  static String tmdb_api_key;

  static String image_NA = "https://1.bp.blogspot.com/-JXjPS9M7MMU/XX39ZP97p4I/AAAAAAAAABE/VQYxrz_roLcXRf5m1nyxTYIxFh7KGow7wCPcBGAYYCw/s1600/df1.jpg";

  static String tmdb_base_url = "https://api.themoviedb.org/3/";
  static String tmdb_base_image_url = "https://image.tmdb.org/t/p/";
  static String language = "&language=en-US"; //hi-IN,en-US,en-IN
  static String region = "&region=US"; //in or us in caps

  static List<Results> trendingMovies = new List<Results>();
  static List<Results> nowPlayingMovies = new List<Results>();
  static List<Results> upcomingMovies = new List<Results>();
  static List<Results> popularMovies = new List<Results>();
  static List<Show> trendingTv = new List<Show>();

  static Map<int, bool> likedMovies = new Map();

  static Map<int, bool> allMovies = new Map();


  static Future<void> findMovieData(User user) async {
    trendingMovies = await findTrendingMovies();
    //trendingTv = await findTrendingShows();
    nowPlayingMovies = await findNowPlayingMovies();
    upcomingMovies = await findUpcomingMovies();
    popularMovies = await findPopularMovies();
    //add all new movie id to peopple
    await addNewMovieinDB(user);
    return;
  }

  static Future<Map<int, bool>> getAllMovies(CollectionReference movies) async {
    Map<int, bool> map = new Map();
    //get already stored movie
    //ToDo every time such heavy read will full the quota,either local persists or commonData
    QuerySnapshot querySnapshot = await movies.get();
    print("pura movie fetch mar rhe, Heavy read");
    print("lentgh of total movies is ${querySnapshot.size}");
    querySnapshot.docs.forEach((doc) {
      //print("Db ka movie id ${doc['movie_id']}");
      map[doc['movie_id']] = doc['liked'];
    });
    allMovies.addAll(map);
    return map;
  }

  static Future<List<Results>> searchMovies(User user, String query) async {
    var url = Uri.parse(
        tmdb_base_url + 'search/movie?api_key=' + tmdb_api_key + language +
            "&query=${query}&include_adult=false");
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    var data = response.body;
    var myjson = jsonDecode(data);

    List<Results> res = TrendingMovies
        .fromJson(myjson)
        .results;

    //enter new values in db

    CollectionReference movies = FirebaseFirestore.instance.collection(
        '/users/' + user.uid + '/movies');

    WriteBatch batch = FirebaseFirestore.instance.batch();
    Map<int, bool> map = allMovies.length == 0
        ? await getAllMovies(movies)
        : allMovies;
    List<int> moviesId = [];
    for (Results r in res) {
      if (!map.containsKey(r.id)) {
        moviesId.add(r.id);
      }
    }

    print("naya movie ka length ${moviesId.length}");
    for (int i in moviesId) {
      // print("movie id is  ${i}");
      allMovies[i] = false;
      DocumentReference documentReference = movies.doc(i.toString());
      batch.set(documentReference, {
        "liked": false,
        "movie_id": i
      });
    }


    await batch.commit();
    return res;
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

    DocumentSnapshot documentSnapshot = await tmdb.doc("tmdb_api_key").get();
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
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('user_name', isEqualTo: username)
        .limit(1)
        .get();
    final List<QueryDocumentSnapshot> documents = result.docs;
    return documents.length == 1;
  }


  static Future<void> getLikedMovies(User user) async {
    likedMovies.clear();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('/users/' + user.uid + '/movies')
        .get();

    querySnapshot.docs.forEach((doc) {
      likedMovies[doc["movie_id"]] = doc["liked"];
    });
  }

  static Future<void> addNewMovieinDB(User user) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    //get already stored movie
    CollectionReference movies = FirebaseFirestore.instance.collection(
        '/users/' + user.uid + '/movies');
    Map<int, bool> map = allMovies.length == 0
        ? await getAllMovies(movies)
        : allMovies;


    List<int> moviesId = new List<int>();
    for (Results r in trendingMovies) {
      if (!map.containsKey(r.id)) {
        moviesId.add(r.id);
      }
    }

    for (Results r in nowPlayingMovies) {
      if (!map.containsKey(r.id)) {
        moviesId.add(r.id);
      }
    }

    for (Results r in upcomingMovies) {
      if (!map.containsKey(r.id)) {
        moviesId.add(r.id);
      }
    }

    for (Results r in popularMovies) {
      if (!map.containsKey(r.id)) {
        moviesId.add(r.id);
      }
    }


    print("naya movie ka length ${moviesId.length}");
    for (int i in moviesId) {
      // print("movie id is  ${i}");
      allMovies[i] = false;
      DocumentReference documentReference = movies.doc(i.toString());
      batch.set(documentReference, {
        "liked": false,
        "movie_id": i
      });
    }
    return await batch.commit();
  }


  static Future<bool> addLikedMovie(User user, int movie_id, bool liked) async {
    CollectionReference movies = FirebaseFirestore.instance.collection(
        '/users/' + user.uid + '/movies');
    //check if movieid exists
    DocumentSnapshot documentSnapshot = await movies.doc(movie_id.toString())
        .get(); //or we can use collection with where
    if (documentSnapshot.exists) {
      print(documentSnapshot.data());
      print("detail exists");
      await movies.doc(movie_id.toString()).update({
        "liked": liked,
        "movie_id": movie_id
      }).then((value) async {
        print("Movie added successfully " + movie_id.toString());
        //await getLikedMovies(user);
        allMovies[movie_id] = liked;
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
        "movie_id": movie_id
      }).then((value) async {
        print("Movie added successfully " + movie_id.toString());
        //await getLikedMovies(user);
        allMovies[movie_id] = liked;
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
    DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();
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
    DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();
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
    DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();
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
    else{
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