import 'package:flutter_test/flutter_test.dart';
import 'package:movies_data/movies_data.dart';

void main() {
  test('fixture traverses the complete accepted relationship graph', () async {
    final catalog = FixtureCatalog();
    final movie = (await catalog.getMovie(900001)).dataOrNull!;
    expect(movie.movie.title, 'Northbound');
    final cast = (await catalog.getCredits(movie.movie.id)).dataOrNull!;
    final person = (await catalog.getPerson(
      cast.cast.first.person.id,
    )).dataOrNull!;
    expect(person.person.name, 'Maya Reed');
    final films = (await catalog.getFilmography(person.person.id)).dataOrNull!;
    expect(films.entries.any((e) => e.movie.id == 900002), isTrue);
    final other = (await catalog.getMovie(900002)).dataOrNull!;
    final collection = (await catalog.getCollection(
      other.collection!.id,
    )).dataOrNull!;
    expect(collection.movies.map((m) => m.id), [900002, 900003]);
  });
  test('missing content and unknown identities remain honest', () async {
    final catalog = FixtureCatalog();
    expect((await catalog.getMovie(900004)).dataOrNull!.collection, isNull);
    expect((await catalog.getTrailers(900004)).dataOrNull, isEmpty);
    expect((await catalog.getMovie(123)).failureOrNull, isNotNull);
    expect((await catalog.searchMovies('   ', 1)).dataOrNull, isNull);
  });
}
