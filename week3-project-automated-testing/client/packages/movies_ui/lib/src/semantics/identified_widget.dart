import 'package:flutter/widgets.dart';

/// A widget key addresses Flutter tests; this also exposes the same identity to
/// native accessibility tools while preserving the child's labels and actions.
extension IdentifiedWidget on Widget {
  Widget identified(String identifier, {bool? toggled}) => MergeSemantics(
    child: Semantics(identifier: identifier, toggled: toggled, child: this),
  );
}
