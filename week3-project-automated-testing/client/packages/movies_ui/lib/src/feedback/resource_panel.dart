import 'dart:async';
import 'package:movies_core/movies_core.dart';
import 'package:flutter/material.dart';

class ResourcePanel extends StatelessWidget {
  const ResourcePanel({
    super.key,
    this.loading = false,
    this.errorText,
    this.displayedSource,
    this.content,
    this.onRetry,
    this.emptyMessage = 'No titles available.',
    this.identifier = 'resource',
  });
  final bool loading;
  final String? errorText;
  final String? displayedSource;
  final Widget? content;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final String identifier;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (displayedSource != null)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Semantics(
            identifier: '$identifier.source',
            child: Text(displayedSource!),
          ),
        ),
      if (errorText != null)
        ErrorNotice(
          message: errorText!,
          onRetry: onRetry,
          identifier: identifier,
        ),
      if (content != null)
        content!
      else if (loading)
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Semantics(
              label: 'Loading content',
              liveRegion: true,
              child: CircularProgressIndicator(),
            ),
          ),
        )
      else if (errorText == null)
        Padding(padding: const EdgeInsets.all(24), child: Text(emptyMessage)),
    ],
  );
}

class ErrorNotice extends StatefulWidget {
  const ErrorNotice({
    super.key,
    required this.message,
    this.onRetry,
    this.identifier = 'resource',
    this.retryNotBeforeUtc,
    this.clock,
    this.schedule,
  });
  final String message;
  final VoidCallback? onRetry;
  final String identifier;
  final DateTime? retryNotBeforeUtc;
  final Clock? clock;
  final Schedule? schedule;
  @override
  State<ErrorNotice> createState() => _ErrorNoticeState();
}

class _ErrorNoticeState extends State<ErrorNotice> {
  Timer? _timer;
  DateTime get _now => widget.clock?.utcNow() ?? DateTime.now().toUtc();
  bool get _cooling => widget.retryNotBeforeUtc?.isAfter(_now) ?? false;
  String get message => widget.message;
  String get identifier => widget.identifier;
  VoidCallback? get onRetry => _cooling ? null : widget.onRetry;
  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(covariant ErrorNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    _arm();
  }

  void _arm() {
    _timer?.cancel();
    if (_cooling) {
      final delay = widget.retryNotBeforeUtc!.difference(_now);
      _timer = (widget.schedule ?? Timer.new)(delay, () {
        if (mounted) {
          setState(() {});
          _arm();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    identifier: '$identifier.error',
    liveRegion: true,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          if (_cooling) const Text('Retry will be available shortly.'),
          if (widget.onRetry != null)
            MergeSemantics(
              child: Semantics(
                identifier: '$identifier.retry',
                child: TextButton(
                  key: ValueKey('$identifier.retry'),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
