Propagate a cancellation request from a CancellationTokenSource to any number of cancellable operations via a CancellationToken.

## Features

- Convey cancellation requests to cancellable operations
- Await the completion of a future with cancellation support
- Await a value on a stream with cancellation support

## Getting started

- Import the library
- Create a "CancellationTokenSource"
- Hand out the CancellationTokenSource's CancellationToken to cancellable operations.
- Cancellable operations should observe the CancellationToken and abort if cancellation is requested.

## Usage

```dart
import 'package:cancellation/cancellation.dart';

void main() {
  final cts = CancellationTokenSource();
  final ct = cts.token;

  final subscription = ct.onCancelled(() => print('ct is cancelled!'));

  print('ct.isCancellationRequested: ${ct.isCancellationRequested}');
  cts.cancel();
  print('ct.isCancellationRequested: ${ct.isCancellationRequested}');

  subscription.cancel();
}

```

## Additional information

Note that with CancellableFutureExtension, a cancellation request does not 'stop' or 'cancel' the original future's execution. It just stops waiting for the future's completion.
