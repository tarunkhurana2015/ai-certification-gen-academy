import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';

class HomeState {
  const HomeState({this.sections = const {}});
  final Map<String, MovieListingState> sections;
  List<MovieSummary> get featured =>
      (sections['trending']?.items ?? const <MovieSummary>[]).take(5).toList();
  List<MovieSummary> shelf(String source) =>
      (sections[source]?.items ?? const <MovieSummary>[]).take(10).toList();
}
