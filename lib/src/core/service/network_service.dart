import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkChecker {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _networkController =
      StreamController<bool>.broadcast();

  NetworkChecker() {
    // Initial check when created
    checkAndEmit();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      checkAndEmit();
    });
  }

  Future<void> checkAndEmit() async {
    final status = await hasInternetConnection();
    _networkController.add(status);
  }

  Future<bool> hasInternetConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool> get networkStatusStream =>
      _networkController.stream.handleError((error) {
        debugPrint('Network error: $error');
        // Consider adding Crashlytics logging here
      });

  void dispose() {
    _networkController.close();
  }
}
