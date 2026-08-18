import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_mobile/core/network/secure_storage_gate.dart';

void main() {
  test(
    'a wedged secure-storage call times out and releases the queue',
    () async {
      final never = Completer<String>();

      final wedged = SecureStorageGate.run(
        () => never.future,
        timeout: const Duration(milliseconds: 20),
      );
      final queued = SecureStorageGate.run(
        () async => 'recovered',
        timeout: const Duration(milliseconds: 100),
      );

      await expectLater(wedged, throwsA(isA<TimeoutException>()));
      expect(await queued, 'recovered');
      expect(SecureStorageGate.busy, isFalse);
    },
  );
}
