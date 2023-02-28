import 'subscription.dart';
import 'cancelled_token.dart';
import 'uncancellable_token.dart';
import 'cancelled_exception.dart';

typedef CancellationCallback = dynamic Function();

/// Object can be used to convey a cancellation request to a cancellable operation
///
/// Cancellation request can be observed by polling the [isCancellationRequested]
/// property or by subscribing a [CancellationCallback] with [onCancelled].
abstract class CancellationToken {
  const CancellationToken();

  /// A [CancellationToken] that is always cancelled
  static const CancellationToken cancelled = CancelledToken();

  /// A [CancellationToken] that cannot be (and will never be) cancelled
  static const CancellationToken uncancellable = UncancellableToken();

  /// Indicates if this [CancellationToken] can be cancelled or not
  ///
  /// If false, [isCancellationRequested] will always be false, and
  /// the [CancellationCallback]s registerde with [onCancelled] will
  /// never be called.
  bool get canBeCancelled;

  /// Indicates that this CancellationToken has been cancelled
  ///
  /// All cancellable operations observing this token should stop and throw
  /// a [CancelledException] where appropriate.
  bool get isCancellationRequested;

  /// Register a callback to be invoked when cancellation is requested
  ///
  /// If a callback is registered after this token has already been cancelled,
  /// the callback is immediately scheduled to run on a microtask.
  CancellationSubscription onCancelled(CancellationCallback callback);
}
