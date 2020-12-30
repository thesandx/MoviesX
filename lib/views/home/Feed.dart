import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_app/models/movie.dart';
import 'dart:math' as math;

import '../../constants.dart';

class Feed extends StatefulWidget {
  Feed({Key key}) : super(key: key);

  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  PageController _pageController;
  int initialPage;
  CarouselController buttonCarouselController;

  @override
  void initState() {
    super.initState();
    initialPage = 0;
    buttonCarouselController = CarouselController();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getHeadLIne(title: "Recent"),
          getSlider(),
          getHeadLIne(title: "Upcoming"),
          getUpcomingList(),
          getHeadLIne(title: "You may like"),
          getUpcomingList()

        ],
      ),
    );
  }

  Widget getHeadLIne({String title}){
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Text("${title}",
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.w800, color: Colors.black)),
    );
  }

  Widget getUpcomingList(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length*2,
        itemBuilder: (context, index) => smallMovieCard(movie: movies[index%movies.length])
      ),
    );

  }

  Widget smallMovieCard({Movie movie}){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 120,
          width: 120,
          padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [kDefaultShadow],
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(movie.poster),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: kDefaultPadding / 2, horizontal: kDefaultPadding),
          child: Text(
            movie.title,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),


      ],

    );
  }

  Widget getSlider(){
    return CarouselSlider(
      options: CarouselOptions(
          height: MediaQuery.of(context).size.height*0.5,
          enlargeCenterPage: true,
          enlargeStrategy: CenterPageEnlargeStrategy.height,
          enableInfiniteScroll: true
      ),
      items: movies.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return MovieCard(movie: i);
          },
        );
      }).toList(),
    );
  }

  Widget MovieCard({Movie movie}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: kDefaultPadding),
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [kDefaultShadow],
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(movie.poster),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: kDefaultPadding / 2, horizontal: kDefaultPadding),
          child: Text(
            movie.title,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Text(
            "${movie.genra}",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontWeight: FontWeight.w200, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
