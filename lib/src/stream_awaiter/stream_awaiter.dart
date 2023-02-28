import 'dart:async';

import 'package:cancellation/cancellation.dart';

extension StreamAwaiter<T> on Stream<T> {
  Future<bool> awaitWhere(
          {final T? initialValue,
          final bool Function(T) matchTrue = neverMatch,
          final bool Function(T) matchFalse = neverMatch,
          final bool cancelOnError = true,
          final bool throwOnError = false,
          final bool throwOnCancel = false,
          final CancellationToken ct = CancellationToken.uncancellable}) =>
      awaitStreamWhere(this,
          matchTrue: matchTrue,
          matchFalse: matchFalse,
          cancelOnError: cancelOnError,
          throwOnError: throwOnError,
          throwOnCancel: throwOnCancel,
          ct: ct);

  Future<bool> awaitValue(final T awaitedValue,
          {final T? initialValue,
          final T? cancelValue,
          final bool cancelOnError = true,
          final bool throwOnError = false,
          final bool throwOnCancel = false,
          final CancellationToken ct = CancellationToken.uncancellable}) =>
      awaitStreamValue(this, awaitedValue,
          cancelValue: cancelValue,
          initialValue: initialValue,
          cancelOnError: cancelOnError,
          throwOnError: throwOnError,
          throwOnCancel: throwOnError,
          ct: ct);
}

/// Wait for specific values to be emitted from a stream
///
/// Returns a future that completes when a value emitted by [stream] matches
/// [matchTrue] or [matchFalse]. If [stream] is closed before a matching value
/// is emitted, the future completes with false.
///
/// If [initialValue] is given and is matched by [matchTrue] or [matchFalse],
/// the future is immediately completed.
///
/// If [stream] emits an error and [throwOnError] is set to true, the future
/// is completed with the same error. If [cancelOnError] is set instead (default),
/// the future is completed with false. I.e. [throwOnError] takes precedence
/// over [cancelOnError]. If neither [throwOnError] nor [cancelOnError] is
/// true, the error is ignored.
///
/// If [ct] is cancelled, and [throwOnCancel] is set true, the future is
/// completed with a [CancelledException]. If [throwOnCancel] is false (default),
/// the future completes with false.
Future<bool> awaitStreamWhere<T>(final Stream<T> stream,
    {final T? initialValue,
    final bool Function(T) matchTrue = neverMatch,
    final bool Function(T) matchFalse = neverMatch,
    final bool cancelOnError = true,
    final bool throwOnError = false,
    final bool throwOnCancel = false,
    final CancellationToken ct = CancellationToken.uncancellable}) {
  if (initialValue != null) {
    if (matchTrue(initialValue) == true) return Future.value(true);
    if (matchFalse(initialValue) == true) return Future.value(false);
  }

  if (ct.isCancellationRequested) {
    if (throwOnCancel) {
      return Future.error(const CancelledException());
    } else {
      return Future.value(false);
    }
  }

  StreamSubscription<T>? streamSubscription;
  CancellationSubscription? ctSubscription;

  final completer = Completer<bool>();

  void cleanup() {
    streamSubscription?.cancel();
    ctSubscription?.cancel();
    streamSubscription = null;
    ctSubscription = null;
  }

  void complete(bool result) {
    cleanup();
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  void completeError(Object error, [StackTrace? st]) {
    cleanup();
    if (!completer.isCompleted) {
      completer.completeError(error, st);
    }
  }

  ctSubscription = ct.onCancelled(() {
    if (throwOnCancel) {
      completeError(const CancelledException());
    } else {
      complete(false);
    }
  });

  streamSubscription = stream.listen((value) {
    if (matchTrue(value)) complete(true);
    if (matchFalse(value)) complete(false);
  }, onDone: () {
    complete(false);
  }, onError: (Object error, StackTrace st) {
    if (throwOnError) {
      completeError(error, st);
    } else if (cancelOnError) {
      complete(false);
    }
  });

  return completer.future;
}

Future<bool> awaitStreamValue<T>(final Stream<T> stream, final T awaitedValue,
        {final T? initialValue,
        final T? cancelValue,
        final bool cancelOnError = true,
        final bool throwOnError = false,
        final bool throwOnCancel = false,
        final CancellationToken ct = CancellationToken.uncancellable}) =>
    awaitStreamWhere(stream,
        matchTrue: (value) => value == awaitedValue,
        matchFalse: (cancelValue != null)
            ? (value) => value == cancelValue
            : neverMatch,
        initialValue: initialValue,
        cancelOnError: cancelOnError,
        throwOnError: throwOnError,
        throwOnCancel: throwOnCancel,
        ct: ct);

bool neverMatch(dynamic value) => false;
