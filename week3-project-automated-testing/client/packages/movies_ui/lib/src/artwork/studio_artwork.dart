import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Original procedural artwork for the explicitly synthetic Demo catalog.
class StudioArtwork extends StatelessWidget {
  const StudioArtwork({
    super.key,
    required this.title,
    this.showTypography = true,
  });
  final String title;
  final bool showTypography;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      key: const ValueKey('artwork.fixture'),
      painter: _StudioPainter(title, showTypography),
      child: const SizedBox.expand(),
    ),
  );
}

class _StudioPainter extends CustomPainter {
  _StudioPainter(this.title, this.showTypography);
  final String title;
  final bool showTypography;
  @override
  void paint(Canvas canvas, Size size) {
    final seed = title.codeUnits.fold(0, (a, b) => a + b);
    const colors = [
      Color(0xff8d5e46),
      Color(0xff514275),
      Color(0xff3d7478),
      Color(0xff384c74),
      Color(0xff875c73),
    ];
    final accent = colors[seed % colors.length];
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, const Color(0xff17131f)],
        ).createShader(rect),
    );
    final sun = Offset(size.width * .63, size.height * .28);
    canvas.drawCircle(
      sun,
      size.shortestSide * .24,
      Paint()..color = const Color(0xffefcd87).withValues(alpha: .52),
    );
    for (var layer = 0; layer < 4; layer++) {
      final path = Path()..moveTo(0, size.height * (.43 + layer * .1));
      for (var i = 0; i <= 12; i++) {
        final x = size.width * i / 12;
        final y =
            size.height * (.43 + layer * .1) +
            math.sin(i * .65 + seed + layer) * size.height * .09;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(
            accent,
            const Color(0xff111015),
            .35 + layer * .16,
          )!,
      );
    }
    for (var i = 0; i < 18; i++) {
      final x = ((seed * 17 + i * 71) % 997) / 997 * size.width;
      final y = ((seed * 3 + i * 43) % 359) / 359 * size.height * .45;
      canvas.drawCircle(
        Offset(x, y),
        i % 3 == 0 ? 1.2 : .7,
        Paint()..color = Colors.white.withValues(alpha: .55),
      );
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0xcc111015)],
        ).createShader(rect),
    );
    if (!showTypography || size.width < 90) return;
    final label = TextPainter(
      text: const TextSpan(
        text: 'M O V I E S  /  S T U D I O',
        style: TextStyle(
          fontSize: 8,
          color: Color(0xffefcd87),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    label.paint(canvas, Offset(12, size.height * .69));
    final name = TextPainter(
      text: TextSpan(
        text: title.toUpperCase(),
        style: TextStyle(
          fontSize: (size.width * .10).clamp(10, 32).toDouble(),
          height: 1.02,
          color: const Color(0xfff8f7fc),
          fontWeight: FontWeight.w700,
        ),
      ),
      maxLines: 2,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: math.max(1, size.width - 24));
    name.paint(canvas, Offset(12, size.height * .74));
  }

  @override
  bool shouldRepaint(_StudioPainter oldDelegate) =>
      oldDelegate.title != title ||
      oldDelegate.showTypography != showTypography;
}
