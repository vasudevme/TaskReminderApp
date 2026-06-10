// lib/services/js_notification_bridge_web.dart
// Compiled ONLY on web targets. Uses modern dart:js_interop API.
import 'dart:js_interop';

@JS('showNovaPushNotification')
external void _showNovaPushNotification(JSString title, JSString body);

void callJsNotification(String title, String body) {
  try {
    _showNovaPushNotification(title.toJS, body.toJS);
  } catch (e) {
    // If JS helper not loaded yet, silently fail
  }
}
