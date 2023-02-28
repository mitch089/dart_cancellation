/// Represents a subscription of a callback and provides a means to unsubscribe
abstract class CancellationSubscription {
  const CancellationSubscription();

  /// Unsubscribe, so the previously registered callback will not be called
  void cancel();
}
