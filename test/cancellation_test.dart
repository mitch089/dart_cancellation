import 'package:cancellation/cancellation.dart';
import 'package:test/test.dart';

void main() {
  group('Cancellation token tests', () {
    test('Cancellation token test', () {
      final cts = CancellationTokenSource();
      final ct = cts.token;

      int counter = 0;
      ct.onCancelled(() => counter++);
      ct.onCancelled(() => counter++);
      final s3 = ct.onCancelled(() => counter++);

      expect(ct.isCancellationRequested, isFalse);
      expect(ct.canBeCancelled, isTrue);
      expect(counter, isZero);

      s3.cancel();

      cts.cancel();

      expect(ct.isCancellationRequested, isTrue);
      expect(ct.canBeCancelled, isTrue);
      expect(counter, equals(2));
    });
  });
}
