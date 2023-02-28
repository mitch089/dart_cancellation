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
