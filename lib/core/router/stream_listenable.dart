import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a bloc stream to the [Listenable] go_router uses for `refreshListenable`.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
