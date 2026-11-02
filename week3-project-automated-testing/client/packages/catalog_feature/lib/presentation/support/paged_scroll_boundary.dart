import 'package:flutter/widgets.dart';

/// Loads one provider cursor after deliberate user scrolling near the end.
/// Failed, empty-filtered and offstage lists retain their explicit action.
class PagedScrollBoundary extends StatefulWidget {
  const PagedScrollBoundary({
    super.key,
    required this.canRead,
    required this.onRead,
    required this.child,
  });
  final bool canRead;
  final VoidCallback onRead;
  final Widget child;
  @override
  State<PagedScrollBoundary> createState() => _PagedScrollBoundaryState();
}

class _PagedScrollBoundaryState extends State<PagedScrollBoundary> {
  bool _scheduled = false;
  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!_scheduled &&
              widget.canRead &&
              notification.depth == 0 &&
              notification is ScrollUpdateNotification &&
              notification.scrollDelta != 0 &&
              notification.metrics.pixels > 0 &&
              notification.metrics.extentAfter < 200) {
            _scheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scheduled = false;
              if (mounted &&
                  widget.canRead &&
                  TickerMode.valuesOf(context).enabled)
                widget.onRead();
            });
          }
          return false;
        },
        child: widget.child,
      );
}
