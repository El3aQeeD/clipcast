import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit() : super(true) {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected =
          results.any((r) => r != ConnectivityResult.none);
      emit(connected);
    });
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
