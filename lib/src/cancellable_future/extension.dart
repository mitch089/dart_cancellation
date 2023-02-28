import 'dart:async';

import 'package:cancellation/cancellation.dart';

extension CancellableFutureExtension<T> on Future<T> {
  /// Waits for the completion of the future or a cancellation request
  ///
  /// Returns a new future that completes, with the same result, when the
  /// original future completes. If [ct] is cancelled before the original
  /// future completes, the returned future completes with a [CancelledException].
  ///
  /// Note that a cancellation request of [ct] does not 'stop' or 'cancel' the
  /// original future's execution. It just stops waiting for the future's completion.
  Future<T> awaitCancellable(CancellationToken ct) {
    if (!ct.canBeCancelled) {
      return this;
    }

    if (ct.isCancellationRequested) {
      return Future.error(const CancelledException());
    }

    final completer = Completer<T>();
    CancellationSubscription? ctSubscription;

    void cleanUp() {
      ctSubscription?.cancel();
      ctSubscription = null;
    }

    void completeWithValue(T value) {
      if (!completer.isCompleted) {
        completer.complete(value);
      }

      cleanUp();
    }

    void completeWithError(Object error, [StackTrace? stackTrace]) {
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }

      cleanUp();
    }

    then<void>((value) => completeWithValue(value),
        onError: (Object error, StackTrace st) => completeWithError(error, st));

    ctSubscription =
        ct.onCancelled(() => completeWithError(const CancelledException()));

    return completer.future;
  }
}
