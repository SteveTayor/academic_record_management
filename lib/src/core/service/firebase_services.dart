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
      {'email_address': {'address': email}}
    ],
    'subject': 'Your OTP Code',
    'htmlbody': '<div><b>Your OTP code is $otp. It will expire in 5 minutes.</b></div>'
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

  // Create user with email verification
  Future<void> createUserWithEmailVerification({
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
    await _auth.signOut();
  }
}
