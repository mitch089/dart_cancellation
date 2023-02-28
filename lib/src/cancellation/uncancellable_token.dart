import 'token.dart';
import 'subscription.dart';
import 'dummy_subscription.dart';

class UncancellableToken extends CancellationToken {
  const UncancellableToken();

  @override
  bool get canBeCancelled => false;

  @override
  bool get isCancellationRequested => false;

  @override
  CancellationSubscription onCancelled(CancellationCallback callback) =>
      const DummySubscription();
}
