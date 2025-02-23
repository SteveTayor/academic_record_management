import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/screens/auth_screens/login_screen.dart';
import 'features/screens/auth_screens/otp_verification_page.dart';
import 'features/screens/dashborad/dashboard.dart';

class RootPage extends StatelessWidget {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // User is not logged in, show login page
          return const LoginPage();
        } else {
          // User is logged in, check otpVerified
          final user = snapshot.data!;
          return FutureBuilder<bool>(
            future: _checkOtpVerified(user.uid),
            builder: (context, otpVerifiedSnapshot) {
              if (otpVerifiedSnapshot.hasData) {
                if (otpVerifiedSnapshot.data!) {
                  // OTP verified, show dashboard
                  return const DashboardPage();
                } else {
                  // OTP not verified, show OTP verification page
                  return OtpVerificationPage(email: user.email!);
                }
              } else {
                // Loading
                return const CircularProgressIndicator();
              }
            },
          );
        }
      },
    );
  }

  Future<bool> _checkOtpVerified(String uid) async {
    final doc = await _firestore.collection('admins').doc(uid).get();
    final data = doc.data();
    return data?['otpVerified'] ?? false;
  }
}