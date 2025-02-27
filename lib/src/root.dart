import 'package:archival_system/src/features/screens/other_screens/landing_page_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/service/network_service.dart';
import 'features/screens/auth_screens/login_screen.dart';
import 'features/screens/dashborad/dashboard.dart';
import 'features/widgets/no_network.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final NetworkChecker _networkChecker = NetworkChecker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _resetOtpVerifiedIfLoggedIn(); // Add this
  }

  Future<void> _resetOtpVerifiedIfLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('admins').doc(user.uid).update({
        'otpVerified': false,
      });
    }
  }

  @override
  void dispose() {
    _networkChecker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _networkChecker.networkStatusStream,
      builder: (context, networkSnapshot) {
        // Handle network connection state
        if (networkSnapshot.hasError) {
          return const Center(child: Text('Network status error'));
        }

        // Show loading until first network status is determined
        if (!networkSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // No internet connection
        if (!networkSnapshot.data!) {
          return const NoNetworkWidget();
        }

        // Internet available - check authentication state
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            // Handle auth state loading
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // No logged in user
            final user = authSnapshot.data;
            if (user == null) {
              return const LandingPage();
            }

            // User logged in - check OTP verification status
            return FutureBuilder<bool>(
              future: _checkOtpVerified(user.uid),
              builder: (context, otpSnapshot) {
                // Handle OTP verification check loading
                if (otpSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Handle errors in OTP check
                if (otpSnapshot.hasError) {
                  return Scaffold(
                    body: Center(child: Text('Error: ${otpSnapshot.error}')),
                  );
                }

                // Navigate to appropriate screen based on OTP status
                return otpSnapshot.data!
                    ? const DashboardPage()
                    : const LoginPage();
                // : OtpVerificationPage(email: user.email!);
              },
            );
          },
        );
      },
    );
  }

  Future<bool> _checkOtpVerified(String uid) async {
    try {
      final doc = await _firestore.collection('admins').doc(uid).get();
      return doc.exists && (doc.data()?['otpVerified'] ?? false);
    } catch (e) {
      throw Exception('Firestore error: $e');
    }
  }
}
