import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Live 4-bar voice waveform shown inside the mic button while dictating.
///
/// Bar height = phase wave (from [wave]) × observed sound level (from
/// [level], normalized 0..1 with an idle floor so the bars keep moving in
/// silence). Because [level] is part of the listenable, the bars still
/// respond to voice even when reduced motion stops the phase loop.
class MicWaveform extends StatelessWidget {
  const MicWaveform({
    super.key,
    required this.wave,
    required this.level,
    required this.color,
  });

  final Animation<double> wave;
  final ValueListenable<double> level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: AnimatedBuilder(
        animation: Listenable.merge([wave, level]),
        builder: (context, _) {
          final phase = wave.value * 2 * math.pi;
          // Idle floor: bars wiggle gently in silence, jump with voice.
          final lvl = 0.25 + 0.75 * level.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: 3,
                  height:
                      6 + 12 * lvl * (0.55 + 0.45 * math.sin(phase + i * 1.1)),
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
