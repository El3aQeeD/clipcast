enum NotificationPermissionStatus {
  initial,
  loading,
  granted,
  denied,
  skipped,
}

class NotificationPermissionState {
  final NotificationPermissionStatus status;

  const NotificationPermissionState({
    this.status = NotificationPermissionStatus.initial,
  });

  NotificationPermissionState copyWith({
    NotificationPermissionStatus? status,
  }) {
    return NotificationPermissionState(
      status: status ?? this.status,
    );
  }
}
