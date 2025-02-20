// lib/services/auth_service.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // 1) EMAIL REGISTRATION & VERIFICATION
  // ---------------------------------------------------------------------------

  /// Create a user in Firebase Auth, then send them an email verification.
  Future<void> createUserWithEmailVerification({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // 1. Create the user in Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = userCredential.user;

    // 2. Send a verification email
    await user?.sendEmailVerification();

    // 3. Optionally store additional user info in Firestore
    final uid = user?.uid;
    if (uid != null) {
      await _firestore.collection('admins').doc(uid).set({
        'fullName': fullName,
        'email': email,
        'createdAt': DateTime.now(),
        'emailVerified': false,
        'phoneVerified': false,
      });
    }
  }

  /// Check if the current user's email is verified.
  Future<bool> checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    await user.reload(); // Refresh user data from Firebase
    user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Resend the verification email if needed.
  Future<void> resendVerificationEmail() async {
    User? user = _auth.currentUser;
    await user?.sendEmailVerification();
  }

  // ---------------------------------------------------------------------------
  // 2) PHONE (SMS) VERIFICATION
  // ---------------------------------------------------------------------------
  //
  // Firebase's built‑in phone verification automatically handles reCAPTCHA on
  // the web and a system UI on mobile. Once the code is sent, you can use it
  // to sign in (or link) the user.
  
  /// Verify phone number by sending an SMS code.
  /// Returns a [verificationId] which is needed to complete sign‑in.
  Future<String> verifyPhoneNumber(String phoneNumber) async {
    Completer<String> completer = Completer();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This callback is called when verification is done automatically.
        try {
          await _auth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete('AUTO_VERIFIED');
          }
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

  /// Sign in (or link) the user with the given [verificationId] and [smsCode].
  /// This example signs them in directly.
  Future<void> signInWithSmsCode(String verificationId, String smsCode) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  /// Update Firestore to mark the user's phone as verified.
  Future<void> updatePhoneVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('admins').doc(user.uid).update({
        'phoneVerified': true,
      });
    }
  }

  // ---------------------------------------------------------------------------
  // 3) AUTHENTICATION PERSISTENCE & SIGN IN
  // ---------------------------------------------------------------------------

  /// Call this early (e.g., in main()) to set auth persistence.
  Future<void> setAuthPersistence() async {
    // On web, you can choose LOCAL, SESSION, or NONE.
    await _auth.setPersistence(Persistence.LOCAL);
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
Future<void> finalizeMultiFactorSignIn({
  required MultiFactorResolver resolver,
  required String verificationId,
  required String smsCode,
}) async {
  final credential = PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: smsCode,
  );
  final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
  await resolver.resolveSignIn(assertion);
}


  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
