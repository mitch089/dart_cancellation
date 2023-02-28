/// Should be thrown by cancellable operations in response to a cancellation request
class CancelledException implements Exception {
  const CancelledException();
}
