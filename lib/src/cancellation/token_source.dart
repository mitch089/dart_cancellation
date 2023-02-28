import 'token.dart';
import 'subscription.dart';
import 'dummy_subscription.dart';

/// Provides a [CancellationToken] and a means to cancel it
class CancellationTokenSource {
  final _token = _CancellationToken();
  CancellationToken get token => _token;

  void cancel() => _token._cancel();
}

class _CancellationToken extends CancellationToken {
  bool _isCancellationRequested = false;
  List<CancellationCallback>? _callbacks;

  @override
  bool get canBeCancelled => true;

  @override
  bool get isCancellationRequested => _isCancellationRequested;

  @override
  CancellationSubscription onCancelled(CancellationCallback callback) {
    if (_isCancellationRequested) {
      Future.microtask(callback);
      return const DummySubscription();
    } else {
      final callbacks = _callbacks ??= [];
      callbacks.add(callback);
      return _Subscription(this, callback);
    }
  }

  void _cancel() {
    _isCancellationRequested = true;
    final callbacks = _callbacks;
    _callbacks = null;

    callbacks?.forEach((callback) => callback());
  }
}

class _Subscription implements CancellationSubscription {
  final _CancellationToken _token;
  final CancellationCallback _callback;

  const _Subscription(this._token, this._callback);

  @override
  void cancel() {
    _token._callbacks?.remove(_callback);
  }
}
