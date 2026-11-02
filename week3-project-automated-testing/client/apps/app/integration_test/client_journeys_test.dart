import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'package:movies/bootstrap/dependency_bindings.dart';
import 'package:movies_data/movies_data.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var counter = 0;
  Future<void> settle(WidgetTester t) async {
    await t.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 15),
    );
  }

  Future<void> boot(WidgetTester t) async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final db = MoviesDatabase.isolatedTest(
      'movies_test_journey_${DateTime.now().microsecondsSinceEpoch}_${counter++}',
    );
    const config = AppConfig(mode: CatalogMode.fixture);
    await t.pumpWidget(
      MoviesApp(
        key: UniqueKey(),
        config: config,
        dependencies: createDependencies(config, favoritesDatabase: db),
      ),
    );
    await settle(t);
  }

  Finder scroll(String key) => find
      .descendant(
        of: find.byWidgetPredicate(
          (w) => w.key is ValueKey && (w.key! as ValueKey).value == key,
        ),
        matching: find.byType(Scrollable),
      )
      .first;
  Future<void> tap(WidgetTester t, String id, {String? parent}) async {
    final target = find.byKey(ValueKey(id));
    if (parent != null) {
      final source = scroll('$parent.scroll');
      if (target.evaluate().isEmpty) {
        t.state<ScrollableState>(source).position.jumpTo(0);
        await t.pump();
        await t.scrollUntilVisible(target, 240, scrollable: source);
      }
      await t.ensureVisible(target);
    }
    await settle(t);
    await t.tap(target);
    await settle(t);
  }

  Future<void> movie(WidgetTester t) async {
    await tap(
      t,
      'movies.home.carousel.featured.movie.900001.open',
      parent: 'movies.home',
    );
  }

  Future<void> chain(WidgetTester t) async {
    await movie(t);
    await tap(
      t,
      'movies.home.movie.900001.cast.open',
      parent: 'movies.home.movie.900001',
    );
    await tap(
      t,
      'movies.home.movie.900001.cast.credit.fixture-cast-001.open',
      parent: 'movies.home.movie.900001.cast',
    );
    await tap(
      t,
      'movies.home.person.910001.filmography.open',
      parent: 'movies.home.person.910001',
    );
    await tap(
      t,
      'movies.home.person.910001.filmography.movie.900002.open',
      parent: 'movies.home.person.910001.filmography',
    );
    await tap(
      t,
      'movies.home.movie.900002.collection.open',
      parent: 'movies.home.movie.900002',
    );
  }

  Future<void> scenario(
    String id,
    WidgetTester t,
    Future<void> Function() body,
  ) async {
    try {
      await body();
    } catch (error) {
      binding.reportData = {
        'case': id,
        'status': 'failed',
        'reason': error.runtimeType.toString(),
      };
      try {
        await binding.takeScreenshot('$id-failure');
      } catch (_) {}
      rethrow;
    }
  }

  testWidgets(
    'MOV-SHELL-002 native deep branch retains page and scroll',
    (t) async => scenario('MOV-SHELL-002', t, () async {
      await boot(t);
      await chain(t);
      await tap(
        t,
        'movies.home.collection.920001.movie.900002.open',
        parent: 'movies.home.collection.920001',
      );
      await tap(
        t,
        'movies.home.movie.900002.cast.open',
        parent: 'movies.home.movie.900002',
      );
      final before = t
          .state<ScrollableState>(
            scroll('movies.home.movie.900002.cast.scroll'),
          )
          .position
          .pixels;
      await tap(t, 'movies.shell.tab.search');
      await tap(t, 'movies.shell.tab.home');
      expect(
        find.byKey(const ValueKey('movies.home.movie.900002.cast.screen')),
        findsOneWidget,
      );
      expect(
        t
            .state<ScrollableState>(
              scroll('movies.home.movie.900002.cast.scroll'),
            )
            .position
            .pixels,
        before,
      );
    }),
  );
  testWidgets(
    'MOV-SEARCH-008 native Back preserves query loaded results and scroll',
    (t) async => scenario('MOV-SEARCH-008', t, () async {
      await boot(t);
      await tap(t, 'movies.shell.tab.search');
      final input = find.byKey(const ValueKey('movies.search.query.input'));
      await t.enterText(input, 'a');
      await t.pump(const Duration(milliseconds: 350));
      await settle(t);
      FocusManager.instance.primaryFocus?.unfocus();
      await settle(t);
      final target = find.byKey(
        const ValueKey('movies.search.results.movie.900004.open'),
      );
      await t.scrollUntilVisible(
        target,
        200,
        scrollable: scroll('movies.search.scroll'),
      );
      await settle(t);
      final before = t
          .state<ScrollableState>(scroll('movies.search.scroll'))
          .position
          .pixels;
      expect(before, greaterThan(0));
      await t.tap(target);
      await settle(t);
      await tap(t, 'movies.search.movie.900004.back');
      expect(t.widget<TextField>(input).controller!.text, 'a');
      expect(
        t
            .state<ScrollableState>(scroll('movies.search.scroll'))
            .position
            .pixels,
        closeTo(before, 1),
      );
    }),
  );
  testWidgets(
    'MOV-DEEP-001 native five additional navigation levels',
    (t) async => scenario('MOV-DEEP-001', t, () async {
      await boot(t);
      await binding.takeScreenshot('home');
      await movie(t);
      await binding.takeScreenshot('movie-details');
      await tap(t, 'movies.home.movie.900001.back');
      await chain(t);
      expect(
        find.byKey(const ValueKey('movies.home.collection.920001.screen')),
        findsOneWidget,
      );
      await binding.takeScreenshot('depth-five');
    }),
  );
  testWidgets(
    'MOV-DEEP-002 native exact visited Back path',
    (t) async => scenario('MOV-DEEP-002', t, () async {
      await boot(t);
      await chain(t);
      for (final pair in [
        ('movies.home.collection.920001', 'movies.home.movie.900002'),
        ('movies.home.movie.900002', 'movies.home.person.910001.filmography'),
        ('movies.home.person.910001.filmography', 'movies.home.person.910001'),
        ('movies.home.person.910001', 'movies.home.movie.900001.cast'),
        ('movies.home.movie.900001.cast', 'movies.home.movie.900001'),
      ]) {
        await tap(t, '${pair.$1}.back');
        expect(find.byKey(ValueKey('${pair.$2}.screen')), findsOneWidget);
      }
    }),
  );
  testWidgets(
    'MOV-DEEP-005 native repeated movie shares favorite on distinct path',
    (t) async => scenario('MOV-DEEP-005', t, () async {
      await boot(t);
      await movie(t);
      await tap(
        t,
        'movies.home.movie.900001.favorite',
        parent: 'movies.home.movie.900001',
      );
      await tap(
        t,
        'movies.home.movie.900001.related.open',
        parent: 'movies.home.movie.900001',
      );
      await tap(
        t,
        'movies.home.movie.900001.related.movie.900004.open',
        parent: 'movies.home.movie.900001.related',
      );
      await tap(
        t,
        'movies.home.movie.900004.related.open',
        parent: 'movies.home.movie.900004',
      );
      await tap(
        t,
        'movies.home.movie.900004.related.movie.900001.open',
        parent: 'movies.home.movie.900004.related',
      );
      await t.scrollUntilVisible(
        find.text('Remove favorite'),
        200,
        scrollable: scroll('movies.home.movie.900001.scroll'),
      );
      await settle(t);
      expect(find.text('Remove favorite'), findsOneWidget);
      await tap(t, 'movies.home.movie.900001.back');
      expect(
        find.byKey(const ValueKey('movies.home.movie.900004.related.screen')),
        findsOneWidget,
      );
    }),
  );
}
