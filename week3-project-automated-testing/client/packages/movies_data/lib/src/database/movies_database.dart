import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'movies_database.g.dart';

@DataClassName('FavoriteRecord')
class FavoriteRecords extends Table {
  @override
  String get tableName => 'favorites';
  IntColumn get movieId =>
      integer().customConstraint('NOT NULL CHECK(movie_id > 0)')();
  TextColumn get title =>
      text().customConstraint('NOT NULL CHECK(length(trim(title)) > 0)')();
  TextColumn get originalTitle => text().nullable()();
  TextColumn get posterPath => text().nullable()();
  TextColumn get backdropPath => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  RealColumn get voteAverage => real().nullable()();
  IntColumn get voteCount => integer().nullable()();
  IntColumn get addedOrder =>
      integer().customConstraint('NOT NULL UNIQUE CHECK(added_order > 0)')();
  IntColumn get addedAtUtc => integer()();
  @override
  Set<Column<Object>> get primaryKey => {movieId};
  @override
  List<String> get customConstraints => [
    'CHECK((vote_average IS NULL AND vote_count IS NULL) OR (vote_average IS NOT NULL AND vote_count IS NOT NULL AND vote_average BETWEEN 0 AND 10 AND vote_count > 0))',
  ];
}

@DataClassName('FavoriteMetaRecord')
class FavoriteMeta extends Table {
  @override
  String get tableName => 'favorites_meta';
  IntColumn get singletonId =>
      integer().customConstraint('NOT NULL CHECK(singleton_id = 1)')();
  IntColumn get lastAddedOrder =>
      integer().customConstraint('NOT NULL CHECK(last_added_order >= 0)')();
  @override
  Set<Column<Object>> get primaryKey => {singletonId};
}

class StorageMigrationException implements Exception {}

@DriftDatabase(tables: [FavoriteRecords, FavoriteMeta])
class MoviesDatabase extends _$MoviesDatabase {
  MoviesDatabase(super.executor);
  factory MoviesDatabase.inMemory() => MoviesDatabase(NativeDatabase.memory());
  factory MoviesDatabase.application({bool fixture = false}) => MoviesDatabase(
    driftDatabase(name: fixture ? 'movies_fixture' : 'movies'),
  );

  /// Test-owned native storage; cannot name either ordinary application database.
  factory MoviesDatabase.isolatedTest(String name) {
    if (!RegExp(r'^movies_test_[a-z0-9_]+$').hasMatch(name)) {
      throw ArgumentError.value(
        name,
        'name',
        'Requires a test-owned database name',
      );
    }
    return MoviesDatabase(driftDatabase(name: name));
  }
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(favoriteMeta).insert(
        const FavoriteMetaCompanion(
          singletonId: Value(1),
          lastAddedOrder: Value(0),
        ),
      );
    },
    onUpgrade: (m, from, to) async {
      throw StorageMigrationException();
    },
  );
}
