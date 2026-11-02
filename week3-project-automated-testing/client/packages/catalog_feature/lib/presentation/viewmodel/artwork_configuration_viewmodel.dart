import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import '../providers/repository_providers.dart';

class ArtworkConfigurationState {
  const ArtworkConfigurationState({this.data, this.error, this.loading = true});
  final ImageConfiguration? data;
  final AppFailure? error;
  final bool loading;
}

final artworkConfigurationProvider =
    NotifierProvider<ArtworkConfigurationViewModel, ArtworkConfigurationState>(
      ArtworkConfigurationViewModel.new,
    );
final artworkConfigurationEnabledProvider = Provider<bool>((ref) => false);

class ArtworkConfigurationViewModel
    extends Notifier<ArtworkConfigurationState> {
  bool _alive = true;
  int _generation = 0;
  CancellationHandle? _cancellation;
  late ArtworkConfigurationRepository _repository;
  late Clock _clock;
  @override
  ArtworkConfigurationState build() {
    _repository = ref.read(artworkConfigurationRepositoryProvider);
    _clock = ref.read(clockProvider);
    ref.onDispose(() {
      _alive = false;
      _generation++;
      _cancellation?.cancel();
    });
    Future.microtask(load);
    return const ArtworkConfigurationState();
  }

  Future<void> load({bool refresh = false}) async {
    if (!_alive) return;
    final generation = ++_generation;
    _cancellation?.cancel();
    final cancel = CancellationHandle();
    _cancellation = cancel;
    final previous = state.data;
    state = ArtworkConfigurationState(data: previous);
    Outcome<ImageConfiguration> outcome;
    try {
      outcome = await _repository.getConfiguration(
        options: CatalogReadOptions(
          policy: refresh ? ReadPolicy.refresh : ReadPolicy.cacheFirst,
          cancellation: cancel,
        ),
      );
    } catch (_) {
      outcome = Outcome.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: 'configuration',
          occurredAtUtc: _clock.utcNow(),
        ),
      );
    }
    if (!_alive || generation != _generation || cancel.isCancelled) return;
    state = ArtworkConfigurationState(
      data: outcome.dataOrNull ?? previous,
      error: outcome.failureOrNull,
      loading: false,
    );
  }
}
