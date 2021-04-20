class Results {
  String overview;
  String releaseDate;
  int id;
  String backdropPath;
  List<int> genreIds;
  String originalLanguage;
  String originalTitle;
  String posterPath;
  String title;


  Results(
      {
        this.overview,
        this.releaseDate,
        this.id,
        this.backdropPath,
        this.genreIds,
        this.originalLanguage,
        this.originalTitle,
        this.posterPath,
        this.title,});

  Results.fromJson(Map<String, dynamic> json) {

    overview = json['overview'];
    releaseDate = json['release_date']??"";
    id = json['id'];

    backdropPath = json['backdrop_path'];
    genreIds = json['genre_ids'].cast<int>();

    originalLanguage = json['original_language'];
    originalTitle = json['original_title'];
    posterPath = json['poster_path'];

    title = json['title']??"NA";

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['overview'] = this.overview;
    data['release_date'] = this.releaseDate;
    data['id'] = this.id;
    data['backdrop_path'] = this.backdropPath;
    data['genre_ids'] = this.genreIds;

    data['original_language'] = this.originalLanguage;
    data['original_title'] = this.originalTitle;
    data['poster_path'] = this.posterPath;

    data['title'] = this.title;

    return data;
  }
}