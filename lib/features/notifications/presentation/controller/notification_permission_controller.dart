import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/request_notification_permission_usecase.dart';
import 'notification_permission_state.dart';

class NotificationPermissionController
    extends Cubit<NotificationPermissionState> {
  NotificationPermissionController({
    required RequestNotificationPermissionUseCase
        requestNotificationPermissionUseCase,
  })  : _requestPermission = requestNotificationPermissionUseCase,
        super(const NotificationPermissionState());

  final RequestNotificationPermissionUseCase _requestPermission;

  Future<void> requestPermission() async {
    emit(state.copyWith(status: NotificationPermissionStatus.loading));
    final granted = await _requestPermission();
    emit(
      state.copyWith(
        status: granted
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied,
      ),
    );
  }

  void skip() {
    emit(state.copyWith(status: NotificationPermissionStatus.skipped));
  }
}
