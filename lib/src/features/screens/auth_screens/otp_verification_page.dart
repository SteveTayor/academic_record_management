import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 18,
                children: [
                  const SizedBox(height: 45),
                  const Text('Verify Otp',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('Enter the OTP sent to your email:'),
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      fillColor: Colors.blueGrey.shade50,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey.shade50),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueGrey.shade50),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: InputBorder.none,
                      hintText: 'OTP',
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Didn\'t receive any code? ',
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Resend',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w500),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _isResendOtpLoading ? null : _resendOtp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue.shade800,
                    ),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.blue.shade800),
                        padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                      ),
                      onPressed: _isVerifyLoading ? null : _verifyOtp,
                      child: _isVerifyLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text('Verify OTP',
                                  style: TextStyle(color: Colors.white)),
                            ),
                    ),
                  ),
                  // ElevatedButton(
                  //     style: ButtonStyle(
                  //       backgroundColor:
                  //           WidgetStatePropertyAll(Colors.purple.shade800),
                  //       padding: const WidgetStatePropertyAll(
                  //           EdgeInsets.symmetric(
                  //               horizontal: 20, vertical: 10)),
                  //       shape: WidgetStatePropertyAll(
                  //           RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(15))),
                  //     ),
                  //     onPressed: _isResendOtpLoading ? null : _resendOtp,
                  //     child: _isResendOtpLoading
                  //         ?  const Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 20,),
                  //         child: CircularProgressIndicator(color: Colors.white,),
                  //       )
                  //         : const Padding(
                  //           padding: EdgeInsets.symmetric(horizontal: 20,),
                  //           child: Text(
                  //               'Resend OTP',
                  //               style: TextStyle(color: Colors.white),
                  //             ),
                  //         )),
                  Text(_message, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
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
          Navigator.of(context).pushReplacement(
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
