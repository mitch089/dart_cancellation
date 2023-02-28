import 'dart:async';

import 'package:cancellation/cancellation.dart';
import 'package:cancellation/src/stream_awaiter/stream_awaiter.dart';
import 'package:test/test.dart';

void main() {
  group('Stream awaiter tests', () {
    test('Stream awaiter test', () async {
      final cts1 = CancellationTokenSource();
      final ct1 = cts1.token;

      final cts2 = CancellationTokenSource();
      final ct2 = cts2.token;

      final sc = StreamController<int>.broadcast();
      final stream = sc.stream;

      // Complete at value 7
      expect(stream.awaitValue(7, ct: ct1), completion(isTrue));

      // Complete at value 7
      expect(stream.awaitValue(7, cancelValue: 8, ct: ct1), completion(isTrue));

      // Cancel at value 7
      expect(
          stream.awaitValue(8, cancelValue: 7, ct: ct1), completion(isFalse));

      // Cancel with ct1 (just before 10)
      expect(stream.awaitValue(16, ct: ct1), completion(isFalse));

      // Complete at value 1
      expect(stream.awaitValue(1, ct: ct2), completion(isTrue));

      // Complete at value 1
      expect(stream.awaitValue(1, cancelValue: 8, ct: ct2), completion(isTrue));

      // Cancel at value 1
      expect(
          stream.awaitValue(8, cancelValue: 1, ct: ct2), completion(isFalse));

      // Cancel with ct2 (just before 5)
      expect(stream.awaitValue(5, ct: ct2), completion(isFalse));

      // Cancel with ct2 (just before 5)
      expect(
          stream.awaitValue(5, cancelValue: 8, ct: ct2), completion(isFalse));

      // Cancel with ct2 (just before 5)
      expect(
          stream.awaitValue(8, cancelValue: 7, ct: ct2), completion(isFalse));

      // Cancel with cancelled CancellationToken
      expect(stream.awaitValue(7, ct: CancellationToken.cancelled),
          completion(isFalse));

      // Cancel with cancelled CancellationToken
      expect(
          stream.awaitValue(7, cancelValue: 8, ct: CancellationToken.cancelled),
          completion(isFalse));

      // Cancel with cancelled CancellationToken
      expect(
          stream.awaitValue(8, cancelValue: 7, ct: CancellationToken.cancelled),
          completion(isFalse));

      // Cancel with cancelled CancellationToken
      expect(stream.awaitValue(16, ct: CancellationToken.cancelled),
          completion(isFalse));

      // Cancel with cancelled CancellationToken
      expect(stream.awaitValue(7, ct: CancellationToken.uncancellable),
          completion(isTrue));

      // Complete at value 7
      expect(
          stream.awaitValue(7,
              cancelValue: 8, ct: CancellationToken.uncancellable),
          completion(isTrue));

      // Cancel at value 7
      expect(
          stream.awaitValue(8,
              cancelValue: 7, ct: CancellationToken.uncancellable),
          completion(isFalse));

      // Complete at value 16
      expect(stream.awaitValue(16, ct: CancellationToken.uncancellable),
          completion(isTrue));

      // Cancel when stream closed (after 29)
      expect(stream.awaitValue(100, cancelOnError: false), completion(isFalse));

      // Cancel on error (just before 19)
      expect(stream.awaitValue(20, cancelOnError: true), completion(isFalse));

      // Complete at value 20 (despite earlier error just before 19)
      expect(stream.awaitValue(20, cancelOnError: false), completion(isTrue));

      await Future.forEach(Iterable<int>.generate(30), (i) async {
        switch (i) {
          case 5:
            cts2.cancel();
            break;

          case 10:
            cts1.cancel();
            break;

          case 19:
            sc.addError(Exception("Some Exception"));
            break;
        }

        sc.add(i);
      }).then((value) => sc.close());
    });
  });
}
