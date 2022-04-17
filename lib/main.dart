import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main(){
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Movie> _movies = <Movie>[];
  bool _isLoading  = true;
  bool _isListEmpty = false;
  int _pageNumber = 1;

  @override
  void initState() {
    super.initState();
    _getMovies();
  }

  Future<void> _getMovies() async{

    setState(() {
      _isLoading = true;
    });

    //accesam API-ul
    final Response response = await get(
        Uri.parse('https://yts.mx/api/v2/list_movies.json?quality=3D&page=$_pageNumber'));

    //transformam raspunsul conexiunii (JSON) intr o mapa de tip String (keys) si dynamic (avem si map,set,alte tipuri de date ca si valoare)
    final Map<String, dynamic> result = jsonDecode(response.body) as Map<String, dynamic>;

    final List<Movie> data = <Movie>[];
    //lista de filme din rezultat
    if(result['data']['movies'] != null) {
      final List<dynamic> movies = result['data']['movies'] as List<dynamic>;

      for (int i = 0; i < movies.length; i++) {
        final Map<String, dynamic> item = movies[i] as Map<String, dynamic>;
        data.add(Movie.fromJson(item));
      }
    }

    setState(() {
      _movies.addAll(data);
      _isLoading = false;

      if(result['data']['movies'] == null){
        _isListEmpty = true;
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Movies $_pageNumber'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if(_isListEmpty == false) {
                  _pageNumber++;
                  _getMovies();
                }
              },
            )
          ]
        ),

        body: Builder(
          builder: (BuildContext context) {

            if(_isLoading && _movies.isEmpty){
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: _movies.length,
              itemBuilder: (BuildContext context, int index) {
                final movie = _movies[index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(movie.image),
                    Text(movie.title),
                    Text('${movie.year}'),
                    Text(movie.genres.join(', ')),
                    Text('${movie.rating}'),
                  ],
                );
              },
            );
          }
        )
    );
  }
}

class Movie{

  Movie({
    required this.title,
    required this.year,
    required this.rating,
    required this.genres,
    required this.image,
  });

  //alt+shift -> modificam in mai multe locuri odata
  Movie.fromJson(Map<String, dynamic> item)
      : title = item['title'] as String,
        year = item['year'] as int,
        rating = item['rating'] as double,
        genres = List<String>.from(item['genres'] as List<dynamic>),
        image = item['medium_cover_image'] as String;

  final String title;
  final int year;
  final double rating;
  final List<String> genres;
  final String image;


  //alt+insert -> Generate
  @override
  String toString() {
    return 'Movie{title: $title, year: $year, rating: $rating, genres: $genres, image: $image}';
  }
}


