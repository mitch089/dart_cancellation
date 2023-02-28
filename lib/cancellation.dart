/// Propagate cancellation requests to cancellable operations
///
/// Cancellation request can be observed by polling the
/// [CancellationToken.isCancellationRequested] property or by subscribing a
/// [CancellationCallback] with [CancellationToken.onCancelled].
library cancellation;

export 'src/cancellation/token.dart';
export 'src/cancellation/token_source.dart';
export 'src/cancellation/cancelled_exception.dart';
export 'src/cancellation/subscription.dart';
