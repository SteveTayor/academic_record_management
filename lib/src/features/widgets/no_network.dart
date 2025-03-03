import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../core/service/network_service.dart';

class NoNetworkWidget extends StatefulWidget {
  const NoNetworkWidget({super.key});

  @override
  State<NoNetworkWidget> createState() => _NoNetworkWidgetState();
}

class _NoNetworkWidgetState extends State<NoNetworkWidget>
    with SingleTickerProviderStateMixin {
  final NetworkChecker _networkChecker = NetworkChecker();
  late Stream<bool> _networkStatusStream;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isChecking = false;
  Timer? _checkingTimer;

  @override
  void initState() {
    super.initState();
    _networkStatusStream = _networkChecker.networkStatusStream;

    // Setup animation for the retry button and icon
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkingTimer?.cancel();
    super.dispose();
  }

  void _retryConnection() {
    setState(() {
      _isChecking = true;
    });

    // Simulate checking with a visual indicator
    _checkingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
        context.read<NetworkChecker>().checkAndEmit();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: StreamBuilder<bool>(
        stream: _networkStatusStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            // Show a brief success message before closing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connected to the internet!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pop(context);
              });
            });
            return const SizedBox();
          }

          // Show enhanced no network message
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.red.shade50, Colors.red.shade100],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated icon
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isChecking ? _animation.value : 1.0,
                              child: Icon(
                                _isChecking ? Icons.wifi_find : Icons.wifi_off,
                                size: 80,
                                color: _isChecking
                                    ? Colors.orange
                                    : Colors.red.shade700,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isChecking
                              ? "Checking Connection..."
                              : "No Internet Connection",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isChecking
                              ? "Please wait while we try to reconnect."
                              : "We can't reach our servers. Check your internet connection and try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Interactive retry button
                        ElevatedButton.icon(
                          onPressed: _isChecking ? null : _retryConnection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          icon: _isChecking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(
                            _isChecking ? "Checking..." : "Retry Connection",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Optional: Additional help
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Troubleshooting Tips"),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "• Check your Wi-Fi or mobile data connection"),
                                    Text(
                                        "• Try switching between Wi-Fi and mobile data"),
                                    Text("• Restart your router or modem"),
                                    Text(
                                        "• Check if other apps can access the internet"),
                                    Text("• Restart your device"),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Got it"),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            "Need Help?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
