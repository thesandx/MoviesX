import 'Show.dart';

class TrendingShows {
  int page;
  List<Show> results;
  int totalPages;
  int totalResults;

  TrendingShows({this.page, this.results, this.totalPages, this.totalResults});

  TrendingShows.fromJson(Map<String, dynamic> json) {
    page = json['page'];
    if (json['results'] != null) {
      results = new List<Show>();
      json['results'].forEach((v) {
        results.add(new Show.fromJson(v));
      });
    }
    totalPages = json['total_pages'];
    totalResults = json['total_results'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['page'] = this.page;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    data['total_pages'] = this.totalPages;
    data['total_results'] = this.totalResults;
    return data;
  }
}

