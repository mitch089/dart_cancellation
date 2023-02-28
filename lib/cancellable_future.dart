/// Await the completion of a future with cancellation support
///
/// Note that with CancellableFutureExtension, a cancellation request does not
/// 'stop' or 'cancel' the original future's execution. It just stops waiting
/// for the future's completion.
library cancellable_future;

export 'src/cancellable_future/extension.dart';
