import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hermes_mobile/core/models/hermes_models.dart';
import 'package:hermes_mobile/core/providers.dart';

/// Desktop-compatible Bot Mode face.
///
/// Uploaded/generated/pet pictures come from `profiles.get_asset`. Vector
/// faces use the same shape/color metadata as Desktop and remain live so their
/// eyes can glance and blink instead of displaying a baked initials circle.
class BotAvatar extends ConsumerStatefulWidget {
  const BotAvatar({
    super.key,
    required this.bot,
    this.size = 52,
    this.working = false,
  });

  final HermesBotProfile bot;
  final double size;
  final bool working;

  @override
  ConsumerState<BotAvatar> createState() => _BotAvatarState();
}

class _BotAvatarState extends ConsumerState<BotAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
      _motion.value = 0;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.bot.usesImageAvatar && widget.bot.hasAvatar
        ? ref.watch(botAvatarProvider(widget.bot.name)).value
        : null;
    final color =
        _parseBotColor(widget.bot.color) ??
        Theme.of(context).colorScheme.primaryContainer;

    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _motion,
          builder: (context, _) {
            final phase = _motion.value;
            final bob = math.sin(phase * math.pi * 2) * 0.8;
            final tilt = math.sin(phase * math.pi * 2) * 0.018;
            return Transform.translate(
              offset: Offset(0, bob),
              child: Transform.rotate(
                angle: tilt,
                child: image == null
                    ? CustomPaint(
                        painter: _BotFacePainter(
                          shape: widget.bot.shape ?? 'circle',
                          color: color,
                          phase: phase,
                          working: widget.working,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(widget.size * 0.22),
                        child: Image.memory(
                          image,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, _, _) => CustomPaint(
                            painter: _BotFacePainter(
                              shape: widget.bot.shape ?? 'circle',
                              color: color,
                              phase: phase,
                              working: widget.working,
                            ),
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Color? _parseBotColor(String? raw) {
  if (raw == null) return null;
  final value = raw.trim().replaceFirst('#', '');
  if (value.length != 6 && value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
}

class _BotFacePainter extends CustomPainter {
  const _BotFacePainter({
    required this.shape,
    required this.color,
    required this.phase,
    required this.working,
  });

  final String shape;
  final Color color;
  final double phase;
  final bool working;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 44);
    final body = Paint()..color = color;
    canvas.drawPath(_bodyPath(shape), body);

    final dark = color.computeLuminance() < 0.16;
    final eyeColor = dark ? const Color(0xFFF0E5D2) : const Color(0xDB000000);
    final gazeX = math.sin(phase * math.pi * 2) * 0.8;
    final gazeY = math.cos(phase * math.pi * 4) * 0.25;
    final blinking =
        (phase > 0.475 && phase < 0.505) || (phase > 0.925 && phase < 0.94);
    final eyePaint = Paint()..color = eyeColor;
    if (blinking) {
      eyePaint
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(13.2 + gazeX, 17.2 + gazeY),
        Offset(17.6 + gazeX, 17.2 + gazeY),
        eyePaint,
      );
      canvas.drawLine(
        Offset(22.4 + gazeX, 17.2 + gazeY),
        Offset(26.8 + gazeX, 17.2 + gazeY),
        eyePaint,
      );
    } else {
      final eyeHeight = working ? 2.55 : 2.3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(15.4 + gazeX, 17.2 + gazeY),
          width: 4.4,
          height: eyeHeight * 2,
        ),
        eyePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(24.6 + gazeX, 17.2 + gazeY),
          width: 4.4,
          height: eyeHeight * 2,
        ),
        eyePaint,
      );
      final shine = Paint()..color = Colors.white.withValues(alpha: 0.82);
      canvas.drawCircle(Offset(14.8 + gazeX, 16.5 + gazeY), 0.62, shine);
      canvas.drawCircle(Offset(24 + gazeX, 16.5 + gazeY), 0.62, shine);
    }

    if (working) {
      for (var i = 0; i < 3; i++) {
        final wave = (math.sin((phase * math.pi * 2) - i * 1.4) + 1) / 2;
        canvas.drawCircle(
          Offset(16.4 + (i * 3.6), 41.1),
          1.1,
          Paint()..color = color.withValues(alpha: 0.25 + wave * 0.75),
        );
      }
    }
    canvas.restore();
  }

  Path _bodyPath(String rawShape) {
    final shape = rawShape.toLowerCase();
    return switch (shape) {
      'squircle' || 'blob' =>
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, 3, 34, 34),
            const Radius.circular(11),
          ),
        ),
      'pill' =>
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(2, 7, 36, 26),
            const Radius.circular(13),
          ),
        ),
      'triangle' =>
        Path()
          ..moveTo(20, 4)
          ..lineTo(37, 35)
          ..lineTo(3, 35)
          ..close(),
      'hexagon' || 'cube' || 'icosahedron' =>
        Path()
          ..moveTo(20, 3.5)
          ..lineTo(34.5, 11.75)
          ..lineTo(34.5, 28.25)
          ..lineTo(20, 36.5)
          ..lineTo(5.5, 28.25)
          ..lineTo(5.5, 11.75)
          ..close(),
      'octahedron' =>
        Path()
          ..moveTo(20, 3)
          ..lineTo(36, 20)
          ..lineTo(20, 37)
          ..lineTo(4, 20)
          ..close(),
      'tetrahedron' =>
        Path()
          ..moveTo(20, 5)
          ..lineTo(36, 33)
          ..lineTo(4, 33)
          ..close(),
      'drop' =>
        Path()
          ..moveTo(20, 3)
          ..cubicTo(20, 3, 6, 20, 6, 27)
          ..cubicTo(6, 35, 12.5, 40, 20, 40)
          ..cubicTo(27.5, 40, 34, 35, 34, 27)
          ..cubicTo(34, 20, 20, 3, 20, 3)
          ..close(),
      'cloud' =>
        Path()
          ..moveTo(11, 32)
          ..cubicTo(2, 32, 2, 18, 10, 17)
          ..cubicTo(11, 5, 27, 3, 29, 12.5)
          ..cubicTo(39, 12, 40, 30, 30, 32)
          ..close(),
      _ =>
        Path()..addOval(
          Rect.fromCircle(center: const Offset(20, 20), radius: 17.5),
        ),
    };
  }

  @override
  bool shouldRepaint(covariant _BotFacePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.shape != shape ||
      oldDelegate.color != color ||
      oldDelegate.working != working;
}
