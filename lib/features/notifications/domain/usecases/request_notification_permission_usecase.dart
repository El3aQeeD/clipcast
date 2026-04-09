import 'package:onesignal_flutter/onesignal_flutter.dart';

class RequestNotificationPermissionUseCase {
  /// Requests push-notification permission via OneSignal.
  /// Returns `true` when the user grants permission.
  Future<bool> call() async {
    final accepted =
        await OneSignal.Notifications.requestPermission(true);
    return accepted;
  }
}
