import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:hermes_mobile/core/health/apple_health_sync.dart';

void main() {
  test('HealthKit request covers every coaching category', () {
    final types = AppleHealthSync.types.toSet();

    expect(types.length, AppleHealthSync.types.length);
    expect(
      types,
      containsAll(<HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.WORKOUT,
        HealthDataType.WEIGHT,
        HealthDataType.BODY_FAT_PERCENTAGE,
        HealthDataType.HEART_RATE,
        HealthDataType.HEART_RATE_VARIABILITY_SDNN,
        HealthDataType.BLOOD_OXYGEN,
        HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
        HealthDataType.RESPIRATORY_RATE,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_WRIST_TEMPERATURE,
        HealthDataType.DIETARY_ENERGY_CONSUMED,
        HealthDataType.MINDFULNESS,
      ]),
    );
  });

  test('daily step intervals use local calendar boundaries', () {
    final intervals = AppleHealthSync.dailyStepIntervals(
      DateTime(2026, 8, 14, 18, 30),
      DateTime(2026, 8, 16, 10),
    );

    expect(intervals, hasLength(3));
    expect(intervals.first.start, DateTime(2026, 8, 14));
    expect(intervals.first.end, DateTime(2026, 8, 15));
    expect(intervals.last.start, DateTime(2026, 8, 16));
    expect(intervals.last.end, DateTime(2026, 8, 17));
  });

  test('daily step payload is deterministic and marked authoritative', () {
    final payload = AppleHealthSync.dailyStepPayload(
      start: DateTime(2026, 8, 15),
      end: DateTime(2026, 8, 16),
      total: 58377,
    );

    expect(payload['uuid'], 'hermes-go-healthkit-daily-steps:2026-08-15');
    expect(payload['sourceId'], AppleHealthSync.dailyStepSourceId);
    expect(payload['value'], {
      '__type': 'NumericHealthValue',
      'numericValue': 58377.0,
    });
  });
}
