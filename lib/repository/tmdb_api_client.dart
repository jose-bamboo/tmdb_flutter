import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tmdbflutter/barrels/models.dart';
import 'package:tmdbflutter/models/actor_info_model.dart';
import 'package:tmdbflutter/models/builder/filter_builder.dart';
import 'package:tmdbflutter/models/cast_model.dart';
import 'package:tmdbflutter/models/movieinfo/MovieInfo.dart';
import 'package:tmdbflutter/models/season_model.dart';
import 'package:tmdbflutter/models/tvshow_model.dart';
import 'package:tmdbflutter/models/tvshowcredits_model.dart';
import 'package:tmdbflutter/repository/search_results_repository.dart';
import 'package:tmdbflutter/repository/uri_generator.dart';

import '../barrels/models.dart';

class TMDBApiClient {
  final String apiKey = "efd2f9bdbe60bbb9414be9a5a20296b0";
  final baseUrl = "api.themoviedb.org";
  final version = '/3';
  final http.Client httpClient;
  late final UriLoader uriLoader;

  TMDBApiClient({required this.httpClient}) {
    uriLoader = TMDBUriLoader(baseUrl, version, apiKey);
  }

  Future<List<GenresModel>> fetchCategories() async {
    List<GenresModel> genres = [];
    final url = '/genre/movie/list';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['genres']
        .forEach((data) => genres.add(GenresModel.fromJson(data)));
    return genres;
  }

  Future<List<GenericMoviesModel>> fetchPopular() async {
    List<GenericMoviesModel> popularMovies = [];
    final path = '/discover/movie';
    final filter = FilterBuilder().sortBy().page(1);
    final uri = uriLoader.generateUri(path, filter.toJson());
    final response = await httpClient.get(uri);
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['results'].forEach(
        (data) => popularMovies.add(GenericMoviesModel.fromJson(data)));
    return popularMovies;
  }

  Future<List<GenericMoviesModel>> fetchUpcoming() async {
    List<GenericMoviesModel> upcomingMovies = [];
    final url = '/movie/upcoming';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['results'].forEach(
        (data) => upcomingMovies.add(GenericMoviesModel.fromJson(data)));
    return upcomingMovies;
  }

  Future<List<GenericMoviesModel>> fetchTrending() async {
    List<GenericMoviesModel> trendingMovies = [];
    final url = '/trending/movie/week';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['results'].forEach(
        (data) => trendingMovies.add(GenericMoviesModel.fromJson(data)));
    return trendingMovies;
  }

  Future<List<ActorsModel>> fetchActors() async {
    List<ActorsModel> actors = [];
    final url = '/person/popular';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['results']
        .forEach((data) => actors.add(ActorsModel.fromJson(data)));
    return actors;
  }

  Future<List<GenericMoviesModel>> fetchNowPlaying({int? page}) async {
    List<GenericMoviesModel> nowPlaying = [];
    final url = '/movie/now_playing';
    final filters = FilterBuilder().page(page);
    final response = await httpClient.get(uriLoader.generateUri(
      url,
      filters.toJson(),
    ));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['results']
        .forEach((data) => nowPlaying.add(GenericMoviesModel.fromJson(data)));
    return nowPlaying;
  }

  Future<List<TVShowModel>> fetchPopularTvShows({int? page}) async {
    List<TVShowModel> tvShows = [];
    // https://api.themoviedb.org/3/discover/tv?api_key=efd2f9bdbe60bbb9414be9a5a20296b0&language=en-US&sort_by=popularity.desc&page=1&timezone=America%2FNew_York&include_null_first_air_dates=false
    final url =
        '/discover/tv&language=en-US&sort_by=popularity.desc&page=$page';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['results']
        .forEach((data) => tvShows.add(TVShowModel.fromJson(data)));
    return tvShows;
  }

  Future<MovieInfo> fetchMovieInfo({int? id}) async {
    //https://api.themoviedb.org/3/movie/419704?api_key=efd2f9bdbe60bbb9414be9a5a20296b0&language=en-US&append_to_response=videos
    final url = '/movie/$id&language=en-US&append_to_response=videos';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    MovieInfo movieInfo = MovieInfo.fromJson(decodeJson);
    return movieInfo;
  }

  Future<List<CastModel>> fetchMovieCasts({int? id}) async {
    List<CastModel> casts = [];
    final url = '/movie/$id/credits';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodeJson = jsonDecode(response.body);
    decodeJson['cast'].forEach((data) => casts.add(CastModel.fromJson(data)));
    return casts;
  }

  Future<TvShowCreditsModel> fetchTvShowCredits({int? id}) async {
    final url = '/tv/$id/credits';
    final response = await httpClient.get(uriLoader.generateUri(url));
    if (response.statusCode != 200) {
      throw new Exception('There was a problem.');
    }
    final decodedJson = jsonDecode(response.body);
    TvShowCreditsModel tvShowCreditsModel =
        TvShowCreditsModel.fromJson(decodedJson);
    return tvShowCreditsModel;
  }

  Future<ActorInfoModel> fetchActorInfo({int? id}) async {
    final url = '/person/$id&language=en-US';
    final response = await httpClient.get(uriLoader.generateUri(url));
    final decodedJson = jsonDecode(response.body);
    ActorInfoModel actorInfoModel = ActorInfoModel.fromJson(decodedJson);
    return actorInfoModel;
  }

  Future<List<GenericMoviesModel>> fetchSimilarMovies({int? id}) async {
    List<GenericMoviesModel> similarMovies = [];
    final url = '/movie/$id/similar&language=en-US&page=1';
    final response = await httpClient.get(uriLoader.generateUri(url));
    final decodeJson = jsonDecode(response.body);
    decodeJson['results'].forEach(
        (data) => similarMovies.add(GenericMoviesModel.fromJson(data)));
    return similarMovies;
  }

  Future<List<TVShowModel>> fetchSimilarTvShows({int? id}) async {
    List<TVShowModel> similarTvShows = [];
    final url = '/tv/$id/similar&language=en-US&page=1';
    final response = await httpClient.get(uriLoader.generateUri(url));
    final decodeJson = jsonDecode(response.body);
    decodeJson['results']
        .forEach((data) => similarTvShows.add(TVShowModel.fromJson(data)));
    return similarTvShows;
  }

  Future<List<GenericMoviesModel>> fetchMoviesByGenre(
      {int? id, int? page}) async {
    List<GenericMoviesModel> moviesByGenre = [];
    final url = '/discover/movie';
    final filters =
        FilterBuilder().sortBy().includeAdult().page(page).withGenres(id);
    final response =
        await httpClient.get(uriLoader.generateUri(url, filters.toJson()));
    final decodeJson = jsonDecode(response.body);
    decodeJson['results'].forEach(
        (movie) => moviesByGenre.add(GenericMoviesModel.fromJson(movie)));
    return moviesByGenre;
  }

  Future<List<GenericMoviesModel>> fetchActorMovies({int? id}) async {
    List<GenericMoviesModel> actorMovies = [];
    final url = '/discover/movie';
    final filters = FilterBuilder();
    final filterMap =
        filters.sortBy().includeAdult().page(1).withCast(id).toJson();
    final response =
        await httpClient.get(uriLoader.generateUri(url, filterMap));
    final decodeJson = jsonDecode(response.body);
    decodeJson['results'].forEach(
        (movie) => actorMovies.add(GenericMoviesModel.fromJson(movie)));
    return actorMovies;
  }

  Future<List<SeasonModel>> fetchTvSeasons({int? id}) async {
    //  https://api.themoviedb.org/3/tv/456?api_key=efd2f9bdbe60bbb9414be9a5a20296b0&language=en-US
    List<SeasonModel> seasons = [];
    final url = '/tv/$id&language=en-US';
    final response = await httpClient.get(uriLoader.generateUri(url));
    final decodeJson = jsonDecode(response.body);
    decodeJson['seasons']
        .forEach((season) => seasons.add(SeasonModel.fromJson(season)));
    return seasons;
  }

  Future fetchSearchResults({String? type, String? query, int? page}) async {
    SearchResultsRepository searchResults =
        DefaultSearchResults(uriLoader, httpClient);
    switch (type) {
      case 'movie':
        searchResults = MovieSearchResults(uriLoader, httpClient);
        break;
      case 'person':
        searchResults = PersonSearchResults(uriLoader, httpClient);
        break;
      case 'tv':
        searchResults = TvSearchResults(uriLoader, httpClient);
        break;
      case 'clear':
        return [];
    }
    return await searchResults.searchMovies(query, page);
  }
}
