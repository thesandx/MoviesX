class WatchProvider {
  int id;
  WatchResults results;

  WatchProvider({this.id, this.results});

  WatchProvider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    results =
    json['results'] != null ? new WatchResults.fromJson(json['results']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.results != null) {
      data['results'] = this.results.toJson();
    }
    return data;
  }
}

class WatchResults {
  IN iN;

  WatchResults({this.iN});

  WatchResults.fromJson(Map<String, dynamic> json) {
    iN = json['IN'] != null ? new IN.fromJson(json['IN']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.iN != null) {
      data['IN'] = this.iN.toJson();
    }
    return data;
  }
}

class IN {
  String link;
  List<Flatrate> flatrate;

  IN({this.link, this.flatrate});

  IN.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    if (json['flatrate'] != null) {
      flatrate = new List<Flatrate>();
      json['flatrate'].forEach((v) {
        flatrate.add(new Flatrate.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['link'] = this.link;
    if (this.flatrate != null) {
      data['flatrate'] = this.flatrate.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Flatrate {
  int displayPriority;
  String logoPath;
  int providerId;
  String providerName;

  Flatrate(
      {this.displayPriority,
        this.logoPath,
        this.providerId,
        this.providerName});

  Flatrate.fromJson(Map<String, dynamic> json) {
    displayPriority = json['display_priority'];
    logoPath = json['logo_path'];
    providerId = json['provider_id'];
    providerName = json['provider_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['display_priority'] = this.displayPriority;
    data['logo_path'] = this.logoPath;
    data['provider_id'] = this.providerId;
    data['provider_name'] = this.providerName;
    return data;
  }
}