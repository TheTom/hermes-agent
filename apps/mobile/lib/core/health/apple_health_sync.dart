import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:uuid/uuid.dart';

import 'package:hermes_mobile/core/network/connection_store.dart';
import 'package:hermes_mobile/core/network/dashboard_client.dart';

/// Read-only HealthKit bridge. HealthKit remains the phone-side source of
/// truth; only the incremental cursor is persisted locally. Samples are sent
/// to the user's authenticated Hermes gateway in bounded, idempotent batches.
class AppleHealthSync {
  AppleHealthSync({required this.gatewayId, required this.dashboard});

  final String gatewayId;
  final DashboardClient dashboard;
  final Health _health = Health();

  static const dailyStepSourceId = 'app.hermes.go.healthkit.statistics.daily';
  static const dailyStepAggregationVersion = 1;

  /// HealthKit data used by the private gateway dataset. Keep this broad: a
  /// coach cannot infer which measurements the user records, and HealthKit's
  /// consent sheet remains the place where the user narrows access.
  static const types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.APPLE_MOVE_TIME,
    HealthDataType.APPLE_STAND_HOUR,
    HealthDataType.APPLE_STAND_TIME,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.DISTANCE_CYCLING,
    HealthDataType.DISTANCE_SWIMMING,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.WALKING_SPEED,
    HealthDataType.WORKOUT,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.WALKING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.ATRIAL_FIBRILLATION_BURDEN,
    HealthDataType.HIGH_HEART_RATE_EVENT,
    HealthDataType.LOW_HEART_RATE_EVENT,
    HealthDataType.IRREGULAR_HEART_RATE_EVENT,
    HealthDataType.ELECTROCARDIOGRAM,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.PERIPHERAL_PERFUSION_INDEX,
    HealthDataType.ELECTRODERMAL_ACTIVITY,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.LEAN_BODY_MASS,
    HealthDataType.HEIGHT,
    HealthDataType.WAIST_CIRCUMFERENCE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.SLEEP_WRIST_TEMPERATURE,
    HealthDataType.INSULIN_DELIVERY,
    HealthDataType.MINDFULNESS,
    HealthDataType.WATER,
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.DIETARY_CARBS_CONSUMED,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.DIETARY_FATS_CONSUMED,
    HealthDataType.DIETARY_FIBER,
    HealthDataType.DIETARY_SUGAR,
    HealthDataType.DIETARY_CAFFEINE,
    HealthDataType.DIETARY_SODIUM,
    HealthDataType.HEADACHE_NOT_PRESENT,
    HealthDataType.HEADACHE_MILD,
    HealthDataType.HEADACHE_MODERATE,
    HealthDataType.HEADACHE_SEVERE,
    HealthDataType.HEADACHE_UNSPECIFIED,
  ];

  static const authorizationVersion = 2;

  String get _enabledKey => 'hermes_go_health_enabled:$gatewayId';
  String get _cursorKey => 'hermes_go_health_cursor:$gatewayId';
  String get _diagnosticsKey => 'hermes_go_health_diagnostics:$gatewayId';
  String get _authorizationVersionKey =>
      'hermes_go_health_authorization_version:$gatewayId';
  String get _dailyStepVersionKey =>
      'hermes_go_health_daily_step_version:$gatewayId';
  final _storage = ConnectionStore.durableSecureStorage();

  Future<bool> get isEnabled async =>
      (await _storage.read(key: _enabledKey)) == 'true';

  Future<bool> get needsAuthorizationReview async =>
      (await _storage.read(key: _authorizationVersionKey)) !=
      '$authorizationVersion';

  Future<void> setEnabled(bool value) async {
    if (value) {
      await _storage.write(key: _enabledKey, value: 'true');
    } else {
      await _storage.delete(key: _enabledKey);
    }
  }

  Future<void> forgetLocalState() async {
    await _storage.delete(key: _enabledKey);
    await _storage.delete(key: _cursorKey);
    await _storage.delete(key: _diagnosticsKey);
    await _storage.delete(key: _authorizationVersionKey);
    await _storage.delete(key: _dailyStepVersionKey);
  }

  Future<Map<String, int>> get lastReadCounts async {
    final raw = await _storage.read(key: _diagnosticsKey);
    if (raw == null) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const {};
      return decoded.map(
        (key, value) => MapEntry('$key', (value as num?)?.toInt() ?? 0),
      );
    } catch (_) {
      return const {};
    }
  }

  Future<bool> requestReadAuthorization() async {
    if (!Platform.isIOS) return false;
    await _health.configure();
    final granted = await _health.requestAuthorization(
      types,
      permissions: List.filled(types.length, HealthDataAccess.READ),
    );
    if (granted) {
      await _storage.write(
        key: _authorizationVersionKey,
        value: '$authorizationVersion',
      );
      await setEnabled(true);
    }
    return granted;
  }

  Future<AppleHealthSyncResult> sync({bool initial = false}) async {
    if (!Platform.isIOS || !await isEnabled) {
      return const AppleHealthSyncResult(skipped: true);
    }
    final capability = await dashboard.appleHealthStatus();
    if (capability == null) {
      throw StateError(
        'The Apple Health plugin is not installed on this gateway',
      );
    }
    await _health.configure();
    final now = DateTime.now().toUtc();
    final saved = await _storage.read(key: _cursorKey);
    final cursor = DateTime.tryParse(saved ?? '');
    // One-day overlap catches delayed Watch writes; server UUID upserts make it
    // safe. First consent gets 30 useful days without an enormous history dump.
    final sampleStart = initial || cursor == null
        ? now.subtract(const Duration(days: 30))
        : cursor.toUtc().subtract(const Duration(days: 1));
    final needsDailyStepBackfill =
        await _storage.read(key: _dailyStepVersionKey) !=
        '$dailyStepAggregationVersion';
    final dailyStepStart = needsDailyStepBackfill
        ? now.subtract(const Duration(days: 30))
        : sampleStart;
    // Query each type separately. Besides preventing one unavailable HealthKit
    // type from aborting the whole sync, this gives the UI an honest account
    // of what the phone actually returned (HealthKit does not disclose denied
    // read permissions directly).
    final payloads = <Map<String, dynamic>>[];
    final readByType = <String, int>{};
    final errors = <String>[];
    for (final type in types) {
      if (type == HealthDataType.STEPS) {
        continue;
      }
      try {
        final values = await _health.getHealthDataFromTypes(
          types: [type],
          startTime: sampleStart,
          endTime: now,
        );
        payloads.addAll(values.map((value) => value.toJson()));
        readByType[type.name] = values.length;
      } catch (error) {
        readByType[type.name] = 0;
        errors.add(type.name);
        debugPrint('AppleHealthSync: could not read ${type.name}: $error');
      }
    }
    var dailyStepsSucceeded = false;
    try {
      final dailySteps = <Map<String, dynamic>>[];
      for (final interval in dailyStepIntervals(dailyStepStart, now)) {
        final total = await _health.getTotalStepsInInterval(
          interval.start,
          interval.end,
        );
        if (total != null) {
          dailySteps.add(
            dailyStepPayload(
              start: interval.start,
              end: interval.end,
              total: total,
            ),
          );
        }
      }
      payloads.addAll(dailySteps);
      readByType[HealthDataType.STEPS.name] = dailySteps.length;
      dailyStepsSucceeded = true;
    } catch (error) {
      readByType[HealthDataType.STEPS.name] = 0;
      errors.add(HealthDataType.STEPS.name);
      debugPrint('AppleHealthSync: could not read daily STEPS: $error');
    }
    var accepted = 0;
    const batchSize = 500;
    for (var offset = 0; offset < payloads.length; offset += batchSize) {
      final end = (offset + batchSize).clamp(0, payloads.length);
      final payload = payloads.sublist(offset, end);
      final response = await dashboard.syncAppleHealth({
        'schema_version': 1,
        'device_id': _health.deviceId,
        'batch_id': const Uuid().v4(),
        'app_version': '37',
        'samples': payload,
      });
      accepted += (response['accepted'] as num?)?.toInt() ?? 0;
    }
    await _storage.write(key: _cursorKey, value: now.toIso8601String());
    await _storage.write(key: _diagnosticsKey, value: jsonEncode(readByType));
    if (dailyStepsSucceeded) {
      await _storage.write(
        key: _dailyStepVersionKey,
        value: '$dailyStepAggregationVersion',
      );
    }
    debugPrint('AppleHealthSync: ${payloads.length} read, $accepted accepted');
    return AppleHealthSyncResult(
      read: payloads.length,
      accepted: accepted,
      readByType: readByType,
      failedTypes: errors,
    );
  }

  @visibleForTesting
  static List<({DateTime start, DateTime end})> dailyStepIntervals(
    DateTime start,
    DateTime end,
  ) {
    final localStart = start.toLocal();
    final localEnd = end.toLocal();
    var day = DateTime(localStart.year, localStart.month, localStart.day);
    final intervals = <({DateTime start, DateTime end})>[];
    while (day.isBefore(localEnd)) {
      final nextDay = DateTime(day.year, day.month, day.day + 1);
      intervals.add((start: day, end: nextDay));
      day = nextDay;
    }
    return intervals;
  }

  @visibleForTesting
  static Map<String, dynamic> dailyStepPayload({
    required DateTime start,
    required DateTime end,
    required int total,
  }) {
    final date = [
      start.year.toString().padLeft(4, '0'),
      start.month.toString().padLeft(2, '0'),
      start.day.toString().padLeft(2, '0'),
    ].join('-');
    return {
      'uuid': 'hermes-go-healthkit-daily-steps:$date',
      'type': HealthDataType.STEPS.name,
      'dateFrom': start.toIso8601String(),
      'dateTo': end.toIso8601String(),
      'value': {
        '__type': 'NumericHealthValue',
        'numericValue': total.toDouble(),
      },
      'unit': HealthDataUnit.COUNT.name,
      'sourceName': 'Apple Health daily total',
      'sourceId': dailyStepSourceId,
      'recordingMethod': 'automatic',
    };
  }
}

class AppleHealthSyncResult {
  const AppleHealthSyncResult({
    this.read = 0,
    this.accepted = 0,
    this.skipped = false,
    this.readByType = const {},
    this.failedTypes = const [],
  });
  final int read;
  final int accepted;
  final bool skipped;
  final Map<String, int> readByType;
  final List<String> failedTypes;

  int get sleepRead => readByType.entries
      .where((entry) => entry.key.startsWith('SLEEP_'))
      .fold(0, (sum, entry) => sum + entry.value);
}
