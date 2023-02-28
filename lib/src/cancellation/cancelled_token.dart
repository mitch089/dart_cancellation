import 'token.dart';
import 'subscription.dart';
import 'dummy_subscription.dart';

class CancelledToken extends CancellationToken {
  const CancelledToken();

  @override
  bool get canBeCancelled => true;

  @override
  bool get isCancellationRequested => true;

  @override
  CancellationSubscription onCancelled(CancellationCallback callback) {
    Future.microtask(callback);
    return const DummySubscription();
  }
}
