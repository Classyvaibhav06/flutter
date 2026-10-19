import 'package:flutter/foundation.dart';

/// Bridges session-expiry events from the network layer to the widget
/// layer without coupling Dio interceptors to any Cubit.
class SessionManager {
  final ValueNotifier<String?> _expiryMessage = ValueNotifier<String?>(null);

  ValueListenable<String?> get expiryMessage => _expiryMessage;

  void expireSession(String message) {
    _expiryMessage.value = message;
  }

  void consume() {
    _expiryMessage.value = null;
  }
}
