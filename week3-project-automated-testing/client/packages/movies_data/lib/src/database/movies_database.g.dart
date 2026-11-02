// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movies_database.dart';

// ignore_for_file: type=lint
class $FavoriteRecordsTable extends FavoriteRecords
    with TableInfo<$FavoriteRecordsTable, FavoriteRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _movieIdMeta = const VerificationMeta(
    'movieId',
  );
  @override
  late final GeneratedColumn<int> movieId = GeneratedColumn<int>(
    'movie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK(movie_id > 0)',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK(length(trim(title)) > 0)',
  );
  static const VerificationMeta _originalTitleMeta = const VerificationMeta(
    'originalTitle',
  );
  @override
  late final GeneratedColumn<String> originalTitle = GeneratedColumn<String>(
    'original_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropPathMeta = const VerificationMeta(
    'backdropPath',
  );
  @override
  late final GeneratedColumn<String> backdropPath = GeneratedColumn<String>(
    'backdrop_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voteAverageMeta = const VerificationMeta(
    'voteAverage',
  );
  @override
  late final GeneratedColumn<double> voteAverage = GeneratedColumn<double>(
    'vote_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voteCountMeta = const VerificationMeta(
    'voteCount',
  );
  @override
  late final GeneratedColumn<int> voteCount = GeneratedColumn<int>(
    'vote_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedOrderMeta = const VerificationMeta(
    'addedOrder',
  );
  @override
  late final GeneratedColumn<int> addedOrder = GeneratedColumn<int>(
    'added_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE CHECK(added_order > 0)',
  );
  static const VerificationMeta _addedAtUtcMeta = const VerificationMeta(
    'addedAtUtc',
  );
  @override
  late final GeneratedColumn<int> addedAtUtc = GeneratedColumn<int>(
    'added_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    movieId,
    title,
    originalTitle,
    posterPath,
    backdropPath,
    releaseDate,
    voteAverage,
    voteCount,
    addedOrder,
    addedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('movie_id')) {
      context.handle(
        _movieIdMeta,
        movieId.isAcceptableOrUnknown(data['movie_id']!, _movieIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('original_title')) {
      context.handle(
        _originalTitleMeta,
        originalTitle.isAcceptableOrUnknown(
          data['original_title']!,
          _originalTitleMeta,
        ),
      );
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('backdrop_path')) {
      context.handle(
        _backdropPathMeta,
        backdropPath.isAcceptableOrUnknown(
          data['backdrop_path']!,
          _backdropPathMeta,
        ),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('vote_average')) {
      context.handle(
        _voteAverageMeta,
        voteAverage.isAcceptableOrUnknown(
          data['vote_average']!,
          _voteAverageMeta,
        ),
      );
    }
    if (data.containsKey('vote_count')) {
      context.handle(
        _voteCountMeta,
        voteCount.isAcceptableOrUnknown(data['vote_count']!, _voteCountMeta),
      );
    }
    if (data.containsKey('added_order')) {
      context.handle(
        _addedOrderMeta,
        addedOrder.isAcceptableOrUnknown(data['added_order']!, _addedOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_addedOrderMeta);
    }
    if (data.containsKey('added_at_utc')) {
      context.handle(
        _addedAtUtcMeta,
        addedAtUtc.isAcceptableOrUnknown(
          data['added_at_utc']!,
          _addedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {movieId};
  @override
  FavoriteRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRecord(
      movieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}movie_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      originalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_title'],
      ),
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      backdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_path'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_date'],
      ),
      voteAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vote_average'],
      ),
      voteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vote_count'],
      ),
      addedOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_order'],
      )!,
      addedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}added_at_utc'],
      )!,
    );
  }

  @override
  $FavoriteRecordsTable createAlias(String alias) {
    return $FavoriteRecordsTable(attachedDatabase, alias);
  }
}

class FavoriteRecord extends DataClass implements Insertable<FavoriteRecord> {
  final int movieId;
  final String title;
  final String? originalTitle;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;
  final int addedOrder;
  final int addedAtUtc;
  const FavoriteRecord({
    required this.movieId,
    required this.title,
    this.originalTitle,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
    required this.addedOrder,
    required this.addedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['movie_id'] = Variable<int>(movieId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || originalTitle != null) {
      map['original_title'] = Variable<String>(originalTitle);
    }
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || backdropPath != null) {
      map['backdrop_path'] = Variable<String>(backdropPath);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<String>(releaseDate);
    }
    if (!nullToAbsent || voteAverage != null) {
      map['vote_average'] = Variable<double>(voteAverage);
    }
    if (!nullToAbsent || voteCount != null) {
      map['vote_count'] = Variable<int>(voteCount);
    }
    map['added_order'] = Variable<int>(addedOrder);
    map['added_at_utc'] = Variable<int>(addedAtUtc);
    return map;
  }

  FavoriteRecordsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteRecordsCompanion(
      movieId: Value(movieId),
      title: Value(title),
      originalTitle: originalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(originalTitle),
      posterPath: posterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPath),
      backdropPath: backdropPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backdropPath),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      voteAverage: voteAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(voteAverage),
      voteCount: voteCount == null && nullToAbsent
          ? const Value.absent()
          : Value(voteCount),
      addedOrder: Value(addedOrder),
      addedAtUtc: Value(addedAtUtc),
    );
  }

  factory FavoriteRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRecord(
      movieId: serializer.fromJson<int>(json['movieId']),
      title: serializer.fromJson<String>(json['title']),
      originalTitle: serializer.fromJson<String?>(json['originalTitle']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      backdropPath: serializer.fromJson<String?>(json['backdropPath']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      voteAverage: serializer.fromJson<double?>(json['voteAverage']),
      voteCount: serializer.fromJson<int?>(json['voteCount']),
      addedOrder: serializer.fromJson<int>(json['addedOrder']),
      addedAtUtc: serializer.fromJson<int>(json['addedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'movieId': serializer.toJson<int>(movieId),
      'title': serializer.toJson<String>(title),
      'originalTitle': serializer.toJson<String?>(originalTitle),
      'posterPath': serializer.toJson<String?>(posterPath),
      'backdropPath': serializer.toJson<String?>(backdropPath),
      'releaseDate': serializer.toJson<String?>(releaseDate),
      'voteAverage': serializer.toJson<double?>(voteAverage),
      'voteCount': serializer.toJson<int?>(voteCount),
      'addedOrder': serializer.toJson<int>(addedOrder),
      'addedAtUtc': serializer.toJson<int>(addedAtUtc),
    };
  }

  FavoriteRecord copyWith({
    int? movieId,
    String? title,
    Value<String?> originalTitle = const Value.absent(),
    Value<String?> posterPath = const Value.absent(),
    Value<String?> backdropPath = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    Value<double?> voteAverage = const Value.absent(),
    Value<int?> voteCount = const Value.absent(),
    int? addedOrder,
    int? addedAtUtc,
  }) => FavoriteRecord(
    movieId: movieId ?? this.movieId,
    title: title ?? this.title,
    originalTitle: originalTitle.present
        ? originalTitle.value
        : this.originalTitle,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    backdropPath: backdropPath.present ? backdropPath.value : this.backdropPath,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    voteAverage: voteAverage.present ? voteAverage.value : this.voteAverage,
    voteCount: voteCount.present ? voteCount.value : this.voteCount,
    addedOrder: addedOrder ?? this.addedOrder,
    addedAtUtc: addedAtUtc ?? this.addedAtUtc,
  );
  FavoriteRecord copyWithCompanion(FavoriteRecordsCompanion data) {
    return FavoriteRecord(
      movieId: data.movieId.present ? data.movieId.value : this.movieId,
      title: data.title.present ? data.title.value : this.title,
      originalTitle: data.originalTitle.present
          ? data.originalTitle.value
          : this.originalTitle,
      posterPath: data.posterPath.present
          ? data.posterPath.value
          : this.posterPath,
      backdropPath: data.backdropPath.present
          ? data.backdropPath.value
          : this.backdropPath,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      voteAverage: data.voteAverage.present
          ? data.voteAverage.value
          : this.voteAverage,
      voteCount: data.voteCount.present ? data.voteCount.value : this.voteCount,
      addedOrder: data.addedOrder.present
          ? data.addedOrder.value
          : this.addedOrder,
      addedAtUtc: data.addedAtUtc.present
          ? data.addedAtUtc.value
          : this.addedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRecord(')
          ..write('movieId: $movieId, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('voteCount: $voteCount, ')
          ..write('addedOrder: $addedOrder, ')
          ..write('addedAtUtc: $addedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    movieId,
    title,
    originalTitle,
    posterPath,
    backdropPath,
    releaseDate,
    voteAverage,
    voteCount,
    addedOrder,
    addedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRecord &&
          other.movieId == this.movieId &&
          other.title == this.title &&
          other.originalTitle == this.originalTitle &&
          other.posterPath == this.posterPath &&
          other.backdropPath == this.backdropPath &&
          other.releaseDate == this.releaseDate &&
          other.voteAverage == this.voteAverage &&
          other.voteCount == this.voteCount &&
          other.addedOrder == this.addedOrder &&
          other.addedAtUtc == this.addedAtUtc);
}

class FavoriteRecordsCompanion extends UpdateCompanion<FavoriteRecord> {
  final Value<int> movieId;
  final Value<String> title;
  final Value<String?> originalTitle;
  final Value<String?> posterPath;
  final Value<String?> backdropPath;
  final Value<String?> releaseDate;
  final Value<double?> voteAverage;
  final Value<int?> voteCount;
  final Value<int> addedOrder;
  final Value<int> addedAtUtc;
  const FavoriteRecordsCompanion({
    this.movieId = const Value.absent(),
    this.title = const Value.absent(),
    this.originalTitle = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.voteCount = const Value.absent(),
    this.addedOrder = const Value.absent(),
    this.addedAtUtc = const Value.absent(),
  });
  FavoriteRecordsCompanion.insert({
    this.movieId = const Value.absent(),
    required String title,
    this.originalTitle = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.voteCount = const Value.absent(),
    required int addedOrder,
    required int addedAtUtc,
  }) : title = Value(title),
       addedOrder = Value(addedOrder),
       addedAtUtc = Value(addedAtUtc);
  static Insertable<FavoriteRecord> custom({
    Expression<int>? movieId,
    Expression<String>? title,
    Expression<String>? originalTitle,
    Expression<String>? posterPath,
    Expression<String>? backdropPath,
    Expression<String>? releaseDate,
    Expression<double>? voteAverage,
    Expression<int>? voteCount,
    Expression<int>? addedOrder,
    Expression<int>? addedAtUtc,
  }) {
    return RawValuesInsertable({
      if (movieId != null) 'movie_id': movieId,
      if (title != null) 'title': title,
      if (originalTitle != null) 'original_title': originalTitle,
      if (posterPath != null) 'poster_path': posterPath,
      if (backdropPath != null) 'backdrop_path': backdropPath,
      if (releaseDate != null) 'release_date': releaseDate,
      if (voteAverage != null) 'vote_average': voteAverage,
      if (voteCount != null) 'vote_count': voteCount,
      if (addedOrder != null) 'added_order': addedOrder,
      if (addedAtUtc != null) 'added_at_utc': addedAtUtc,
    });
  }

  FavoriteRecordsCompanion copyWith({
    Value<int>? movieId,
    Value<String>? title,
    Value<String?>? originalTitle,
    Value<String?>? posterPath,
    Value<String?>? backdropPath,
    Value<String?>? releaseDate,
    Value<double?>? voteAverage,
    Value<int?>? voteCount,
    Value<int>? addedOrder,
    Value<int>? addedAtUtc,
  }) {
    return FavoriteRecordsCompanion(
      movieId: movieId ?? this.movieId,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      addedOrder: addedOrder ?? this.addedOrder,
      addedAtUtc: addedAtUtc ?? this.addedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (movieId.present) {
      map['movie_id'] = Variable<int>(movieId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (originalTitle.present) {
      map['original_title'] = Variable<String>(originalTitle.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (backdropPath.present) {
      map['backdrop_path'] = Variable<String>(backdropPath.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<String>(releaseDate.value);
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    if (voteCount.present) {
      map['vote_count'] = Variable<int>(voteCount.value);
    }
    if (addedOrder.present) {
      map['added_order'] = Variable<int>(addedOrder.value);
    }
    if (addedAtUtc.present) {
      map['added_at_utc'] = Variable<int>(addedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRecordsCompanion(')
          ..write('movieId: $movieId, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('voteCount: $voteCount, ')
          ..write('addedOrder: $addedOrder, ')
          ..write('addedAtUtc: $addedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $FavoriteMetaTable extends FavoriteMeta
    with TableInfo<$FavoriteMetaTable, FavoriteMetaRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonIdMeta = const VerificationMeta(
    'singletonId',
  );
  @override
  late final GeneratedColumn<int> singletonId = GeneratedColumn<int>(
    'singleton_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK(singleton_id = 1)',
  );
  static const VerificationMeta _lastAddedOrderMeta = const VerificationMeta(
    'lastAddedOrder',
  );
  @override
  late final GeneratedColumn<int> lastAddedOrder = GeneratedColumn<int>(
    'last_added_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK(last_added_order >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [singletonId, lastAddedOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteMetaRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_id')) {
      context.handle(
        _singletonIdMeta,
        singletonId.isAcceptableOrUnknown(
          data['singleton_id']!,
          _singletonIdMeta,
        ),
      );
    }
    if (data.containsKey('last_added_order')) {
      context.handle(
        _lastAddedOrderMeta,
        lastAddedOrder.isAcceptableOrUnknown(
          data['last_added_order']!,
          _lastAddedOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAddedOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonId};
  @override
  FavoriteMetaRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteMetaRecord(
      singletonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_id'],
      )!,
      lastAddedOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_added_order'],
      )!,
    );
  }

  @override
  $FavoriteMetaTable createAlias(String alias) {
    return $FavoriteMetaTable(attachedDatabase, alias);
  }
}

class FavoriteMetaRecord extends DataClass
    implements Insertable<FavoriteMetaRecord> {
  final int singletonId;
  final int lastAddedOrder;
  const FavoriteMetaRecord({
    required this.singletonId,
    required this.lastAddedOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_id'] = Variable<int>(singletonId);
    map['last_added_order'] = Variable<int>(lastAddedOrder);
    return map;
  }

  FavoriteMetaCompanion toCompanion(bool nullToAbsent) {
    return FavoriteMetaCompanion(
      singletonId: Value(singletonId),
      lastAddedOrder: Value(lastAddedOrder),
    );
  }

  factory FavoriteMetaRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteMetaRecord(
      singletonId: serializer.fromJson<int>(json['singletonId']),
      lastAddedOrder: serializer.fromJson<int>(json['lastAddedOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonId': serializer.toJson<int>(singletonId),
      'lastAddedOrder': serializer.toJson<int>(lastAddedOrder),
    };
  }

  FavoriteMetaRecord copyWith({int? singletonId, int? lastAddedOrder}) =>
      FavoriteMetaRecord(
        singletonId: singletonId ?? this.singletonId,
        lastAddedOrder: lastAddedOrder ?? this.lastAddedOrder,
      );
  FavoriteMetaRecord copyWithCompanion(FavoriteMetaCompanion data) {
    return FavoriteMetaRecord(
      singletonId: data.singletonId.present
          ? data.singletonId.value
          : this.singletonId,
      lastAddedOrder: data.lastAddedOrder.present
          ? data.lastAddedOrder.value
          : this.lastAddedOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteMetaRecord(')
          ..write('singletonId: $singletonId, ')
          ..write('lastAddedOrder: $lastAddedOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(singletonId, lastAddedOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteMetaRecord &&
          other.singletonId == this.singletonId &&
          other.lastAddedOrder == this.lastAddedOrder);
}

class FavoriteMetaCompanion extends UpdateCompanion<FavoriteMetaRecord> {
  final Value<int> singletonId;
  final Value<int> lastAddedOrder;
  const FavoriteMetaCompanion({
    this.singletonId = const Value.absent(),
    this.lastAddedOrder = const Value.absent(),
  });
  FavoriteMetaCompanion.insert({
    this.singletonId = const Value.absent(),
    required int lastAddedOrder,
  }) : lastAddedOrder = Value(lastAddedOrder);
  static Insertable<FavoriteMetaRecord> custom({
    Expression<int>? singletonId,
    Expression<int>? lastAddedOrder,
  }) {
    return RawValuesInsertable({
      if (singletonId != null) 'singleton_id': singletonId,
      if (lastAddedOrder != null) 'last_added_order': lastAddedOrder,
    });
  }

  FavoriteMetaCompanion copyWith({
    Value<int>? singletonId,
    Value<int>? lastAddedOrder,
  }) {
    return FavoriteMetaCompanion(
      singletonId: singletonId ?? this.singletonId,
      lastAddedOrder: lastAddedOrder ?? this.lastAddedOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonId.present) {
      map['singleton_id'] = Variable<int>(singletonId.value);
    }
    if (lastAddedOrder.present) {
      map['last_added_order'] = Variable<int>(lastAddedOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteMetaCompanion(')
          ..write('singletonId: $singletonId, ')
          ..write('lastAddedOrder: $lastAddedOrder')
          ..write(')'))
        .toString();
  }
}

abstract class _$MoviesDatabase extends GeneratedDatabase {
  _$MoviesDatabase(QueryExecutor e) : super(e);
  $MoviesDatabaseManager get managers => $MoviesDatabaseManager(this);
  late final $FavoriteRecordsTable favoriteRecords = $FavoriteRecordsTable(
    this,
  );
  late final $FavoriteMetaTable favoriteMeta = $FavoriteMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    favoriteRecords,
    favoriteMeta,
  ];
}

typedef $$FavoriteRecordsTableCreateCompanionBuilder =
    FavoriteRecordsCompanion Function({
      Value<int> movieId,
      required String title,
      Value<String?> originalTitle,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> releaseDate,
      Value<double?> voteAverage,
      Value<int?> voteCount,
      required int addedOrder,
      required int addedAtUtc,
    });
typedef $$FavoriteRecordsTableUpdateCompanionBuilder =
    FavoriteRecordsCompanion Function({
      Value<int> movieId,
      Value<String> title,
      Value<String?> originalTitle,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> releaseDate,
      Value<double?> voteAverage,
      Value<int?> voteCount,
      Value<int> addedOrder,
      Value<int> addedAtUtc,
    });

class $$FavoriteRecordsTableFilterComposer
    extends Composer<_$MoviesDatabase, $FavoriteRecordsTable> {
  $$FavoriteRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voteCount => $composableBuilder(
    column: $table.voteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedOrder => $composableBuilder(
    column: $table.addedOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteRecordsTableOrderingComposer
    extends Composer<_$MoviesDatabase, $FavoriteRecordsTable> {
  $$FavoriteRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voteCount => $composableBuilder(
    column: $table.voteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedOrder => $composableBuilder(
    column: $table.addedOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteRecordsTableAnnotationComposer
    extends Composer<_$MoviesDatabase, $FavoriteRecordsTable> {
  $$FavoriteRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get movieId =>
      $composableBuilder(column: $table.movieId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get voteCount =>
      $composableBuilder(column: $table.voteCount, builder: (column) => column);

  GeneratedColumn<int> get addedOrder => $composableBuilder(
    column: $table.addedOrder,
    builder: (column) => column,
  );

  GeneratedColumn<int> get addedAtUtc => $composableBuilder(
    column: $table.addedAtUtc,
    builder: (column) => column,
  );
}

class $$FavoriteRecordsTableTableManager
    extends
        RootTableManager<
          _$MoviesDatabase,
          $FavoriteRecordsTable,
          FavoriteRecord,
          $$FavoriteRecordsTableFilterComposer,
          $$FavoriteRecordsTableOrderingComposer,
          $$FavoriteRecordsTableAnnotationComposer,
          $$FavoriteRecordsTableCreateCompanionBuilder,
          $$FavoriteRecordsTableUpdateCompanionBuilder,
          (
            FavoriteRecord,
            BaseReferences<
              _$MoviesDatabase,
              $FavoriteRecordsTable,
              FavoriteRecord
            >,
          ),
          FavoriteRecord,
          PrefetchHooks Function()
        > {
  $$FavoriteRecordsTableTableManager(
    _$MoviesDatabase db,
    $FavoriteRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> movieId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> originalTitle = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<int?> voteCount = const Value.absent(),
                Value<int> addedOrder = const Value.absent(),
                Value<int> addedAtUtc = const Value.absent(),
              }) => FavoriteRecordsCompanion(
                movieId: movieId,
                title: title,
                originalTitle: originalTitle,
                posterPath: posterPath,
                backdropPath: backdropPath,
                releaseDate: releaseDate,
                voteAverage: voteAverage,
                voteCount: voteCount,
                addedOrder: addedOrder,
                addedAtUtc: addedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> movieId = const Value.absent(),
                required String title,
                Value<String?> originalTitle = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<int?> voteCount = const Value.absent(),
                required int addedOrder,
                required int addedAtUtc,
              }) => FavoriteRecordsCompanion.insert(
                movieId: movieId,
                title: title,
                originalTitle: originalTitle,
                posterPath: posterPath,
                backdropPath: backdropPath,
                releaseDate: releaseDate,
                voteAverage: voteAverage,
                voteCount: voteCount,
                addedOrder: addedOrder,
                addedAtUtc: addedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$MoviesDatabase,
      $FavoriteRecordsTable,
      FavoriteRecord,
      $$FavoriteRecordsTableFilterComposer,
      $$FavoriteRecordsTableOrderingComposer,
      $$FavoriteRecordsTableAnnotationComposer,
      $$FavoriteRecordsTableCreateCompanionBuilder,
      $$FavoriteRecordsTableUpdateCompanionBuilder,
      (
        FavoriteRecord,
        BaseReferences<_$MoviesDatabase, $FavoriteRecordsTable, FavoriteRecord>,
      ),
      FavoriteRecord,
      PrefetchHooks Function()
    >;
typedef $$FavoriteMetaTableCreateCompanionBuilder =
    FavoriteMetaCompanion Function({
      Value<int> singletonId,
      required int lastAddedOrder,
    });
typedef $$FavoriteMetaTableUpdateCompanionBuilder =
    FavoriteMetaCompanion Function({
      Value<int> singletonId,
      Value<int> lastAddedOrder,
    });

class $$FavoriteMetaTableFilterComposer
    extends Composer<_$MoviesDatabase, $FavoriteMetaTable> {
  $$FavoriteMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAddedOrder => $composableBuilder(
    column: $table.lastAddedOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteMetaTableOrderingComposer
    extends Composer<_$MoviesDatabase, $FavoriteMetaTable> {
  $$FavoriteMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAddedOrder => $composableBuilder(
    column: $table.lastAddedOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteMetaTableAnnotationComposer
    extends Composer<_$MoviesDatabase, $FavoriteMetaTable> {
  $$FavoriteMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonId => $composableBuilder(
    column: $table.singletonId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAddedOrder => $composableBuilder(
    column: $table.lastAddedOrder,
    builder: (column) => column,
  );
}

class $$FavoriteMetaTableTableManager
    extends
        RootTableManager<
          _$MoviesDatabase,
          $FavoriteMetaTable,
          FavoriteMetaRecord,
          $$FavoriteMetaTableFilterComposer,
          $$FavoriteMetaTableOrderingComposer,
          $$FavoriteMetaTableAnnotationComposer,
          $$FavoriteMetaTableCreateCompanionBuilder,
          $$FavoriteMetaTableUpdateCompanionBuilder,
          (
            FavoriteMetaRecord,
            BaseReferences<
              _$MoviesDatabase,
              $FavoriteMetaTable,
              FavoriteMetaRecord
            >,
          ),
          FavoriteMetaRecord,
          PrefetchHooks Function()
        > {
  $$FavoriteMetaTableTableManager(_$MoviesDatabase db, $FavoriteMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                Value<int> lastAddedOrder = const Value.absent(),
              }) => FavoriteMetaCompanion(
                singletonId: singletonId,
                lastAddedOrder: lastAddedOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonId = const Value.absent(),
                required int lastAddedOrder,
              }) => FavoriteMetaCompanion.insert(
                singletonId: singletonId,
                lastAddedOrder: lastAddedOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$MoviesDatabase,
      $FavoriteMetaTable,
      FavoriteMetaRecord,
      $$FavoriteMetaTableFilterComposer,
      $$FavoriteMetaTableOrderingComposer,
      $$FavoriteMetaTableAnnotationComposer,
      $$FavoriteMetaTableCreateCompanionBuilder,
      $$FavoriteMetaTableUpdateCompanionBuilder,
      (
        FavoriteMetaRecord,
        BaseReferences<
          _$MoviesDatabase,
          $FavoriteMetaTable,
          FavoriteMetaRecord
        >,
      ),
      FavoriteMetaRecord,
      PrefetchHooks Function()
    >;

class $MoviesDatabaseManager {
  final _$MoviesDatabase _db;
  $MoviesDatabaseManager(this._db);
  $$FavoriteRecordsTableTableManager get favoriteRecords =>
      $$FavoriteRecordsTableTableManager(_db, _db.favoriteRecords);
  $$FavoriteMetaTableTableManager get favoriteMeta =>
      $$FavoriteMetaTableTableManager(_db, _db.favoriteMeta);
}
