import 'package:flutter/material.dart';
import 'package:movie_app/Services/CommonData.dart';

class MovieProvider extends ChangeNotifier{

  Map<int,bool> likedMovies;

  MovieProvider(){
    likedMovies = CommonData.likedMovies;
  }

  void setChange(Map<int,bool> change){

    likedMovies = change;
    notifyListeners();
  }

}