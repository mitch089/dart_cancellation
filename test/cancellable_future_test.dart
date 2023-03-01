import 'dart:async';

import 'package:cancellation/cancellation.dart';
import 'package:cancellation/cancellable_future.dart';
import 'package:test/test.dart';

void main() {
  test('Completes when underlying completes', () async {
    final cts = CancellationTokenSource();
    final ct = cts.token;

    final underlyingCompleter = Completer<int>();
    final underlyingFuture = underlyingCompleter.future;

    final sut = underlyingFuture.awaitCancellable(ct);

    expect(underlyingFuture, completion(equals(42)));
    expect(sut, completion(equals(42)));

    await Future.forEach(Iterable<int>.generate(3), (i) async {
      switch (i) {
        case 2:
          underlyingCompleter.complete(42);
          break;
      }
    });
  });

  test('Completes when underlying is completed', () async {
    final cts = CancellationTokenSource();
    final ct = cts.token;

    final underlyingFuture = Future.value(42);

    final sut = underlyingFuture.awaitCancellable(ct);

    expect(underlyingFuture, completion(equals(42)));
    expect(sut, completion(equals(42)));
  });

  test('Throws when underlying throws', () async {
    final cts = CancellationTokenSource();
    final ct = cts.token;

    final underlyingCompleter = Completer<int>();
    final underlyingFuture = underlyingCompleter.future;

    final sut = underlyingFuture.awaitCancellable(ct);

    expect(
        underlyingFuture,
        throwsA(isA<Exception>().having(
            (ex) => ex.toString(), "message", contains("Some exception"))));

    expect(
        sut,
        throwsA(isA<Exception>().having(
            (ex) => ex.toString(), "message", contains("Some exception"))));

    await Future.forEach(Iterable<int>.generate(3), (i) async {
      switch (i) {
        case 2:
          underlyingCompleter.completeError(Exception("Some exception"));
          break;
      }
    });
  });

  test('Throws CancelledException when cancelled', () async {
    final cts = CancellationTokenSource();
    final ct = cts.token;

    final underlyingCompleter = Completer<int>();
    final underlyingFuture = underlyingCompleter.future;

    final sut = underlyingFuture.awaitCancellable(ct);

    expect(underlyingFuture, completion(equals(42)));
    expect(sut, throwsA(isA<CancelledException>()));

    await Future.forEach(Iterable<int>.generate(3), (i) async {
      switch (i) {
        case 1:
          cts.cancel();
          break;

        case 2:
          underlyingCompleter.complete(42);
          break;
      }
    });
  });

  test('Throws CancelledException with cancelled token', () async {
    final ct = CancellationToken.cancelled;

    final underlyingCompleter = Completer<int>();
    final underlyingFuture = underlyingCompleter.future;

    final sut = underlyingFuture.awaitCancellable(ct);

    expect(underlyingFuture, completion(equals(42)));
    expect(sut, throwsA(isA<CancelledException>()));

    await Future.forEach(Iterable<int>.generate(3), (i) async {
      switch (i) {
        case 2:
          underlyingCompleter.complete(42);
          break;
      }
    });
  });

  test('Mixed test', () async {
    final cts1 = CancellationTokenSource();
    final cts2 = CancellationTokenSource();

    final ct1 = cts1.token;
    final ct2 = cts2.token;
    const ct3 = CancellationToken.uncancellable;
    const ct4 = CancellationToken.cancelled;

    final underlyingCompleter = Completer<int>();
    final underlyingFuture = underlyingCompleter.future;

    final sut1 = underlyingFuture.awaitCancellable(ct1);
    final sut2 = underlyingFuture.awaitCancellable(ct2);
    final sut3 = underlyingFuture.awaitCancellable(ct3);
    final sut4 = underlyingFuture.awaitCancellable(ct4);

    expect(underlyingFuture, completion(equals(42)));

    expect(sut1, throwsA(isA<CancelledException>()));
    expect(sut2, completion(equals(42)));
    expect(sut3, completion(equals(42)));
    expect(sut4, throwsA(isA<CancelledException>()));

    await Future.forEach([1, 2, 3], (i) async {
      switch (i) {
        case 1:
          cts1.cancel();
          break;

        case 2:
          underlyingCompleter.complete(42);
          break;

        case 3:
          cts2.cancel();
          break;
      }
    });
  });
}
