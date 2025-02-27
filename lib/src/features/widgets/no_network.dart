import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/service/network_service.dart';

class NoNetworkWidget extends StatefulWidget {
  const NoNetworkWidget({super.key});

  @override
  State<NoNetworkWidget> createState() => _NoNetworkWidgetState();
}

class _NoNetworkWidgetState extends State<NoNetworkWidget> {
  final NetworkChecker _networkChecker = NetworkChecker();
  late Stream<bool> _networkStatusStream;

  @override
  void initState() {
    super.initState();
    _networkStatusStream = _networkChecker.networkStatusStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade100,
      body: StreamBuilder<bool>(
        stream: _networkStatusStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            // Close this widget when network is restored
            Future.microtask(() => Navigator.pop(context));
            return const SizedBox();
          }

          // Show no network message
          return Center(
            child: Column(
              spacing: 15,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 100, color: Colors.red.shade700),
                const SizedBox(height: 20),
                const Text(
                  "No Internet Connection",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please check your connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
                // In NoNetworkWidget
ElevatedButton(
  onPressed: () => context.read<NetworkChecker>().checkAndEmit(),
  child: const Text('Retry Connection'),
)
              ],
            ),
          );
        },
      ),
    );
  }
}
