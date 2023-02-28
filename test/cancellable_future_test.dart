import 'dart:async';

import 'package:cancellation/cancellation.dart';
import 'package:cancellation/cancellable_future.dart';
import 'package:test/test.dart';

void main() {
  group('Cancellable future tests', () {
    test('Cancellable future test', () async {
      final cts1 = CancellationTokenSource();
      final cts2 = CancellationTokenSource();

      final ct1 = cts1.token;
      final ct2 = cts2.token;
      const ct3 = CancellationToken.uncancellable;
      const ct4 = CancellationToken.cancelled;

      final completer = Completer<int>();
      final f = completer.future;

      final f1 = f.awaitCancellable(ct1);
      final f2 = f.awaitCancellable(ct2);
      final f3 = f.awaitCancellable(ct3);
      final f4 = f.awaitCancellable(ct4);

      expect(f, completion(equals(42)));

      expect(f1, throwsA(isA<CancelledException>()));
      expect(f2, completion(equals(42)));
      expect(f3, completion(equals(42)));
      expect(f4, throwsA(isA<CancelledException>()));

      await Future.forEach([1, 2, 3], (i) async {
        switch (i) {
          case 1:
            cts1.cancel();
            break;

          case 2:
            completer.complete(42);
            break;

          case 3:
            cts2.cancel();
            break;
        }
      });
    });
  });
}
