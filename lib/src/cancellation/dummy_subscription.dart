import 'subscription.dart';

class DummySubscription extends CancellationSubscription {
  const DummySubscription();

  @override
  void cancel() {}
}
