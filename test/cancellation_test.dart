import 'package:cancellation/cancellation.dart';
import 'package:test/test.dart';

void main() {
  test('Cancellation token test', () {
    final cts = CancellationTokenSource();
    final ct = cts.token;

    int counter1 = 0;
    int counter2 = 0;
    int counter3 = 0;

    ct.onCancelled(() => counter1++);
    ct.onCancelled(() => counter2++);
    final s3 = ct.onCancelled(() => counter3++);

    expect(ct.isCancellationRequested, isFalse);
    expect(ct.canBeCancelled, isTrue);

    expect(counter1, isZero);
    expect(counter2, isZero);
    expect(counter3, isZero);

    s3.cancel();

    cts.cancel();

    expect(ct.isCancellationRequested, isTrue);
    expect(ct.canBeCancelled, isTrue);

    expect(counter1, equals(1));
    expect(counter2, equals(1));
    expect(counter3, equals(0));
  });
}
