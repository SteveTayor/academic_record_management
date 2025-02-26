import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Make sure to add this package

import '../../../core/service/firebase_services.dart';
import '../dashborad/dashboard.dart';

import 'package:firebase_auth/firebase_auth.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  bool _isResendOtpLoading = false;
  bool _isVerifyLoading = false;

  @override
  Widget build(context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SizedBox(
            width: 500,
            child: Form(
              key: _formKey,
              child: _buildOtpVerificationUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpVerificationUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Animate(
          effects: [
            FadeEffect(duration: 500.ms),
            const SlideEffect(begin: Offset(0, -0.1), end: Offset.zero)
          ],
          child: Column(
            children: [
              const SizedBox(height: 45),
              Icon(
                Icons.security,
                size: 70,
                color: Colors.blue.shade800,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Enter the OTP sent to ${widget.email} to complete your registration',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        // OTP input field
        Animate(
          effects: [FadeEffect(duration: 500.ms, delay: 200.ms)],
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              fillColor: Colors.blueGrey.shade50,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              hintText: 'Enter OTP',
              errorStyle: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Animate(
          effects: [FadeEffect(duration: 500.ms, delay: 300.ms)],
          child: Center(
            child: RichText(
              text: TextSpan(
                text: 'Didn\'t receive any code? ',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Resend',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = _isResendOtpLoading
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              _resendOtp();
                            },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Verify OTP button
        Animate(
          effects: [FadeEffect(duration: 500.ms, delay: 400.ms)],
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.blue.shade800,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: _isVerifyLoading
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _verifyOtp();
                      },
                child: Center(
                  child: _isVerifyLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'Verify OTP',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 1, end: 1.02, duration: 2000.ms),
        ),
        const SizedBox(height: 20),
        if (_message.isNotEmpty)
          Animate(
            effects: [FadeEffect(duration: 300.ms)],
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _message,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = _otpController.text.trim();
    if (enteredOtp.isEmpty) {
      setState(() => _message = 'Please enter the OTP.');
      return;
    }
    setState(() {
      _isVerifyLoading = true;
      _message = '';
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final isValid = await _authService.verifyOtp(user.uid, enteredOtp);
        if (isValid) {
          await _authService.markOtpVerified(user.uid);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DashboardPage(),
            ),
          );
        } else {
          setState(() => _message = 'Invalid or expired OTP.');
        }
      }
    } catch (e) {
      setState(() => _message = 'Error verifying OTP: $e');
    } finally {
      setState(() => _isVerifyLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResendOtpLoading = true;
      _message = '';
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reset OTP verification status
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .update({'otpVerified': false});
        final otp = _authService.generateOtp();
        await _authService.storeOtp(user.uid, otp);
        await _authService.sendOtpEmail(user.email!, otp);
        setState(() => _message = 'OTP resent to your email.');
      }
    } catch (e) {
      setState(() => _message = 'Failed to resend OTP: $e');
    } finally {
      setState(() => _isResendOtpLoading = false);
    }
  }
}
