// lib/services/auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // static const String _zeptoMailApiUrl = 'https://api.zeptomail.com/v1.1/email';
  // static const String _apiKey =
  // 'Zoho-enczapikey wSsVR61zqxfzXKl/nGasJr8/nFldD1/2EksviVX3unStH63L8Mcyl0bLBFKvH/dLRzJvFzsW8LkrnB5R2mAJj915zVoIDCiF9mqRe1U4J3x17qnvhDzOW2hVkhqLKYINxAtrmmlnEsAi+g==';
  static const String _fromEmail = 'noreply@joseph-jahazil.name.ng';

  // Generate a 6-digit OTP
  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Store OTP in Firestore with expiration
  Future<void> storeOtp(String uid, String otp) async {
    final expiration = DateTime.now().add(const Duration(minutes: 5));
    await _firestore.collection('admins').doc(uid).update({
      'otp': otp,
      'otpExpiration': expiration,
    });
  }

  // Send OTP via email using ZeptoMail
  Future<void> sendOtpEmail(String email, String otp) async {
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'from': {'address': _fromEmail},
      'to': [
        {
          'email_address': {'address': email}
        }
      ],
      'subject': 'UniVault SignIn OTP Code',
      'htmlbody': '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style type="text/css">
        /* Reset styles */
        body { margin: 0; padding: 0; min-width: 100%; font-family: Arial, sans-serif; }
        table { border-spacing: 0; }
        td { padding: 0; }
        img { border: 0; max-width: 100%; }
    </style>
</head>
<body style="background-color: #f6f6f6; margin: 0; padding: 20px 0;">
    <table width="100%" border="0" cellpadding="0" cellspacing="0" role="presentation">
        <tr>
            <td align="center" style="padding: 20px 0;">
                <!-- Main container -->
                <table width="600" border="0" cellpadding="0" cellspacing="0" role="presentation" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="padding: 30px 40px; border-bottom: 1px solid #eeeeee;">
                            <img src="https://student-portal.ui.edu.ng/images/ui_logo.png" alt="University Logo" width="150" style="display: block; margin: 0 auto;">
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 40px 30px;">
                            <h1 style="color: #333333; margin: 0 0 25px; font-size: 24px;">Your Verification Code</h1>
                            <p style="color: #666666; margin: 0 0 25px; line-height: 1.6;">Please use the following One-Time Password (OTP) to verify your account:</p>
                            
                            <!-- OTP Code -->
                            <div style="background-color: #f8f9fa; border-radius: 6px; padding: 20px; text-align: center; margin: 0 0 30px;">
                                <span style="font-size: 32px; font-weight: bold; color: #2b6cde; letter-spacing: 3px;">$otp</span>
                            </div>
                            
                            <!-- Warning -->
                            <p style="color: #ff4444; margin: 0 0 25px; font-size: 14px;">
                                ⚠️ This code will expire in 5 minutes. Do not share this code with anyone.
                            </p>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="padding: 25px 40px; background-color: #f8f9fa; border-radius: 0 0 8px 8px;">
                            <p style="color: #999999; margin: 0; font-size: 12px; line-height: 1.6;">
                                If you didn't request this code, you can safely ignore this email.<br>
                                © ${DateTime.now().year} University of Ibadan. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
                
                <!-- Support Info -->
                <table width="600" border="0" cellpadding="0" cellspacing="0" role="presentation" style="margin-top: 20px;">
                    <tr>
                        <td>
                            <p style="color: #999999; margin: 0; font-size: 12px; text-align: center;">
                                Need help? Contact us at 
                                <a href="mailto:support@ui.edu.ng" style="color: #2b6cde; text-decoration: none;">support@ui.edu.ng</a>
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
'''
    });

    final response = await http.post(
      Uri.parse('http://localhost:3000/send-email'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP email: ${response.body}');
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String uid, String enteredOtp) async {
    final doc = await _firestore.collection('admins').doc(uid).get();
    final data = doc.data();
    if (data == null) return false;

    final storedOtp = data['otp'] as String?;
    final expiration = data['otpExpiration'] as Timestamp?;

    if (storedOtp == null || expiration == null) return false;

    if (DateTime.now().isAfter(expiration.toDate())) {
      return false; // OTP expired
    }

    return storedOtp == enteredOtp;
  }

  // Mark OTP as verified
  Future<void> markOtpVerified(String uid) async {
    await _firestore.collection('admins').doc(uid).update({
      'otpVerified': true,
      'otp': null,
      'otpExpiration': null,
    });
  }

  Future<Map<String, dynamic>?> getCurrentAdminData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('admins').doc(user.uid).get();
      return doc.data();
    }
    return null;
  }

  // Create user with email verification
  Future<User?> createUserWithEmailVerification({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await user.sendEmailVerification();
      await _firestore.collection('admins').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': DateTime.now(),
        'emailVerified': false,
        'phoneVerified': false,
        'otpVerified': false,
        'otp': null,
        'otpExpiration': null,
      });
    }
    return user;
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  /// Resend the verification email if needed.
  Future<void> resendVerificationEmail() async {
    User? user = _auth.currentUser;
    await user?.sendEmailVerification();
  }
  // ---------------------------------------------------------------------------
  // 3) AUTHENTICATION PERSISTENCE & SIGN IN
  // ---------------------------------------------------------------------------

  /// Call this early (e.g., in main()) to set auth persistence.
  Future<void> setAuthPersistence() async {
    // On web, you can choose LOCAL, SESSION, or NONE.
    await _auth.setPersistence(Persistence.LOCAL);
  }

  // Clear OTP after verification
  Future<void> clearOtp(String uid) async {
    await _firestore.collection('admins').doc(uid).update({
      'otp': null,
      'otpExpiration': null,
    });
  }

  /// Sign in with email and password.
  Future<User?> signInWithEmailPassword(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // ---------------------------------------------------------------------------
  // 4) PASSWORD RESET & SIGN OUT
  // ---------------------------------------------------------------------------

  /// Sends a password reset email to the specified [email].
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Finalizes a multi-factor sign-in using the provided SMS code.
// Future<void> finalizeMultiFactorSignIn({
//   required MultiFactorResolver resolver,
//   required String verificationId,
//   required String smsCode,
// }) async {
//   final credential = PhoneAuthProvider.credential(
//     verificationId: verificationId,
//     smsCode: smsCode,
//   );
//   final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
//   await resolver.resolveSignIn(assertion);
// }

  /// Signs out the current user.
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('admins').doc(user.uid).update({
        'otpVerified': false,
      });
    }
    await _auth.signOut();
  }
}
