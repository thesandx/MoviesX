class Show {
  String originalName;
  List<String> originCountry;
  List<int> genreIds;
  int id;
  int voteCount;
  String firstAirDate;
  String name;
  double voteAverage;
  String originalLanguage;
  String overview;
  String posterPath;
  String backdropPath;
  double popularity;
  String mediaType;

  Show(
      {this.originalName,
        this.originCountry,
        this.genreIds,
        this.id,
        this.voteCount,
        this.firstAirDate,
        this.name,
        this.voteAverage,
        this.originalLanguage,
        this.overview,
        this.posterPath,
        this.backdropPath,
        this.popularity,
        this.mediaType});

  Show.fromJson(Map<String, dynamic> json) {
    originalName = json['original_name'];
    originCountry = json['origin_country'].cast<String>();
    genreIds = json['genre_ids'].cast<int>();
    id = json['id'];
    voteCount = json['vote_count'];
    firstAirDate = json['first_air_date'];
    name = json['name'];
    voteAverage = json['vote_average'];
    originalLanguage = json['original_language'];
    overview = json['overview'];
    posterPath = json['poster_path'];
    backdropPath = json['backdrop_path'];
    popularity = json['popularity'];
    mediaType = json['media_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['original_name'] = this.originalName;
    data['origin_country'] = this.originCountry;
    data['genre_ids'] = this.genreIds;
    data['id'] = this.id;
    data['vote_count'] = this.voteCount;
    data['first_air_date'] = this.firstAirDate;
    data['name'] = this.name;
    data['vote_average'] = this.voteAverage;
    data['original_language'] = this.originalLanguage;
    data['overview'] = this.overview;
    data['poster_path'] = this.posterPath;
    data['backdrop_path'] = this.backdropPath;
    data['popularity'] = this.popularity;
    data['media_type'] = this.mediaType;
    return data;
  }
}
