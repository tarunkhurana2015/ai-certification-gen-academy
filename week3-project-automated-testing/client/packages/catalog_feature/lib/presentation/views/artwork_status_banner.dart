import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_ui/movies_ui.dart';
import '../providers/repository_providers.dart';
import '../viewmodel/artwork_configuration_viewmodel.dart';

class ArtworkStatusBanner extends ConsumerWidget {
  const ArtworkStatusBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(artworkConfigurationEnabledProvider))
      return const SizedBox.shrink();
    final state = ref.watch(artworkConfigurationProvider);
    if (state.error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ErrorNotice(
        identifier: 'movies.shell.artwork',
        retryNotBeforeUtc: state.error!.retryNotBeforeUtc,
        clock: ref.read(clockProvider),
        message: 'Movie artwork could not be refreshed.',
        onRetry: state.error!.retryAllowed
            ? () => ref
                  .read(artworkConfigurationProvider.notifier)
                  .load(refresh: true)
            : null,
      ),
    );
  }
}
