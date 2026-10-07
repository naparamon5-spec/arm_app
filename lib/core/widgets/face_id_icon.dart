import 'package:flutter/material.dart';

/// Minimal Face ID–style glyph: four corner brackets, two eyes, a nose and
/// a smile, drawn as simple strokes.
class FaceIdIcon extends StatelessWidget {
  const FaceIdIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _FaceIdPainter(c)),
    );
  }
}

class _FaceIdPainter extends CustomPainter {
  _FaceIdPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = s * 0.08;
    final arm = s * 0.22;
    final r = s * 0.12;
    final l = inset, t = inset, rt = s - inset, b = s - inset;

    // Corner brackets with rounded corners.
    canvas.drawPath(
        Path()
          ..moveTo(l, t + arm)
          ..lineTo(l, t + r)
          ..quadraticBezierTo(l, t, l + r, t)
          ..lineTo(l + arm, t),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(rt - arm, t)
          ..lineTo(rt - r, t)
          ..quadraticBezierTo(rt, t, rt, t + r)
          ..lineTo(rt, t + arm),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(rt, b - arm)
          ..lineTo(rt, b - r)
          ..quadraticBezierTo(rt, b, rt - r, b)
          ..lineTo(rt - arm, b),
        paint);
    canvas.drawPath(
        Path()
          ..moveTo(l + arm, b)
          ..lineTo(l + r, b)
          ..quadraticBezierTo(l, b, l, b - r)
          ..lineTo(l, b - arm),
        paint);

    // Eyes.
    canvas.drawLine(Offset(s * 0.35, s * 0.36), Offset(s * 0.35, s * 0.44), paint);
    canvas.drawLine(Offset(s * 0.65, s * 0.36), Offset(s * 0.65, s * 0.44), paint);

    // Nose.
    canvas.drawPath(
        Path()
          ..moveTo(s * 0.5, s * 0.36)
          ..lineTo(s * 0.5, s * 0.55)
          ..lineTo(s * 0.45, s * 0.55),
        paint);

    // Smile.
    canvas.drawPath(
        Path()
          ..moveTo(s * 0.36, s * 0.66)
          ..quadraticBezierTo(s * 0.5, s * 0.76, s * 0.64, s * 0.66),
        paint);
  }

  @override
  bool shouldRepaint(_FaceIdPainter old) => old.color != color;
}
