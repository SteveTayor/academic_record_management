import 'package:archival_system/src/features/screens/dashborad/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/service/firebase_services.dart';
import 'enum.dart';
import 'login_screen.dart';
import 'validation.dart';

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({Key? key}) : super(key: key);

  @override
  _AdminRegistrationPageState createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  final AuthService _authService = AuthService();

  RegistrationStep _currentStep = RegistrationStep.signUp;
  VerificationMethod? _selectedMethod = VerificationMethod.email;

  // For phone verification
  String? _verificationId;
  final _smsCodeController = TextEditingController();

  // For UI feedback
  bool _isRegistered = false;
  bool _isVerified = false;
  String _message = '';

  bool _obscureConfirmPassword = true;

  bool _obscurePassword = true;

  bool _isSignUpLoading = false;
  bool _isResendEmailLoading = false;
  bool _isLoading = false;
  bool _isOtpSentLoading = false;
  bool _isVerifyLoading = false;
  bool _isResendOtpLoadin = false;
  bool _isEmailVerificationLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              spacing: 18,
              children: [
                Container(
                  width: 470,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.lightBlue.withOpacity(.2),
                              child: Icon(Icons.safety_check_sharp,
                                  size: 25, color: Colors.blue.shade600),
                            ),
                            const Text(
                              'UniVault Admin Registration',
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Secure registration for approved administrators',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey.shade300,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/images/university-of-ibadan-logo-transparent.png',
                        height: 80,
                        width: 100,
                        fit: BoxFit.fitHeight,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 500,
                  child: Card(
                    color: Colors.white,
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 25),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildContent() {
  //   // If not yet registered, show the sign-up form.
  //   if (!_isRegistered) {
  //     return _buildSignUpForm();
  //   }

  //   // If registered but not verified.
  //   if (!_isVerified) {
  //     if (_selectedMethod == VerificationMethod.email) {
  //       return _buildEmailVerificationWait();
  //     } else {
  //       return _buildPhoneVerificationUI();
  //     }
  //   }

  //   // If user is verified.
  //   return _buildSuccessScreen();
  // }
  Widget _buildContent() {
    switch (_currentStep) {
      case RegistrationStep.signUp:
        return _buildSignUpForm();
      case RegistrationStep.emailVerification:
        return _buildEmailVerificationWait();
      case RegistrationStep.otpVerification:
        return _buildOtpVerificationUI();
      case RegistrationStep.complete:
        return _buildSuccessScreen();
    }
  }

  // ---------------------------------------------------------------------------
  // 1) SIGN-UP FORM (with complex validation)
  // ---------------------------------------------------------------------------
  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sign Up',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Divider(
            color: Colors.grey.withOpacity(.3),
          ),
          const SizedBox(height: 25),
          const Text('Full Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
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
              suffixIcon: const Icon(Icons.person_outline_outlined,
                  size: 15, color: Colors.black),
              hintText: 'Enter your Full Name',
            ),
            // onChanged: (value) {
            //   setState(() {
            //     _fullNameController.text = value;
            //   });
            //   if (value.isNullOrEmpty) 'Full Name is required.';
            //   if (!value.isValidName) 'Enter a valid name.';
            //   return null;
            // },
            validator: (value) {
              if (value.isNullOrEmpty) return 'Full Name is required.';
              if (!value.isValidName) return 'Enter a valid name.';
              return null;
            },
          ),

          const Text('Email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.next,
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
              hintText: 'Enter your Email',
              suffixIcon: const Icon(Icons.email_outlined,
                  size: 15, color: Colors.black),
            ),
            // onChanged: (value) {
            //   setState(() {
            //     _emailController.text = value;
            //   });
            //   if (value.isNullOrEmpty) 'Email is required.';
            //   if (!value.isValidEmail) 'Enter a valid email address.';
            //   return null;
            // },
            validator: (value) {
              if (value.isNullOrEmpty) return 'Email is required.';
              if (!value.isValidEmail) return 'Enter a valid email address.';
              return null;
            },
          ),

          const Text('Phone number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          TextFormField(
            controller: _phoneController,
            textInputAction: TextInputAction.next,
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
              hintText: 'Enter your Phone Number',
              suffixIcon: const Icon(Icons.phone_enabled_outlined,
                  size: 15, color: Colors.black),
            ),
            // onChanged: (value) {
            //   setState(() {
            //     _phoneController.text = value;
            //   });
            //   if (value.isNullOrEmpty) 'Phone number is required.';
            //   if (!value.isValidPhone) 'Enter a valid phone number.';
            //   return null;
            // },
            validator: (value) {
              if (value.isNullOrEmpty) return 'Phone number is required.';
              if (!value.isValidPhone) return 'Enter a valid phone number.';
              return null;
            },
          ),

          const Text('Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
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
              hintText: 'Password',
              suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                child: Icon(
                  _obscurePassword == true
                      ? Icons.lock_outline
                      : Icons.remove_red_eye,
                  size: 15,
                  color: Colors.black,
                ),
              ),
            ),
            // onChanged: (value) {
            //   setState(() {
            //     _passwordController.text = value;
            //   });
            //   if (value.isNullOrEmpty) 'Password is required.';
            //   if (!value.isValidPassword) {
            //     'Password must be at least 8 characters and include uppercase, lowercase, digit, and special character.';
            //   }
            //   return null;
            // },
            validator: (value) {
              if (value.isNullOrEmpty) return 'Password is required.';
              if (!value.isValidPassword) {
                return 'Password must be at least 8 characters and include uppercase, lowercase, digit, and special character.';
              }
              return null;
            },
          ),

          const Text('Confirm Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
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
              hintText: 'Confirm Password',
              suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                child: Icon(
                  _obscureConfirmPassword
                      ? Icons.lock_outline
                      : Icons.remove_red_eye,
                  size: 15,
                  color: Colors.black,
                ),
              ),
            ),
            // onChanged: (value) {
            //   setState(() {
            //     _confirmPasswordController.text = value;
            //   });
            //   if (value.isNullOrEmpty) 'Please confirm your password.';
            //   if (!value.isPasswordMatch(_passwordController.text)) {
            //     'Passwords do not match.';
            //   }
            //   return null;
            // },
            validator: (String? value) {
              if (value!.isNullOrEmpty) return 'Please confirm your password.';
              if (!value.isPasswordMatch(_passwordController.text)) {
                return 'Passwords do not match.';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          // Radio Buttons: Choose verification method.
          Row(
            children: [
              Radio<VerificationMethod>(
                value: VerificationMethod.email,
                groupValue: _selectedMethod,
                onChanged: (val) {
                  setState(() => _selectedMethod = val!);
                },
              ),
              const Text('Verify by Email'),
              // const SizedBox(width: 20),
              // Radio<VerificationMethod>(
              //   value: VerificationMethod.phone,
              //   groupValue: _selectedMethod,
              //   onChanged: (val) {
              //     setState(() => _selectedMethod = val!);
              //   },
              // ),
              // const Text('Verify by Phone (SMS)'),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.darken,
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue.shade800,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isSignUpLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : InkWell(
                        onTap: _handleSignUp,
                        child: const Text('Sign Up',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
              ),
            ),
          ),
          Center(
            child: RichText(
                text: TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: Colors.black, fontSize: 14),
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to the login screen.redred
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  text: ' Login',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade400,
                      fontWeight: FontWeight.w500),
                ),
              ],
            )),
          ),

          Text(
            _message,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2) WAITING FOR EMAIL VERIFICATION
  // ---------------------------------------------------------------------------
  Widget _buildEmailVerificationWait() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 25,
      children: [
        const Text(
          'A verification link has been sent to your email. Please verify.',
          textAlign: TextAlign.center,
        ),

        Row(
          children: [
            Container(
              width: 150,
              decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.darken,
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue.shade800,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: _isEmailVerificationLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : InkWell(
                        onTap: _checkEmailVerificationStatus,
                        child: Flexible(
                          child: const Text('I have verified, continue',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                      ),
              ),
            ),
            SizedBox(
              width: 30,
            ),
            Expanded(
              child: Container(
                width: 150,
                decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.darken,
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue.shade800,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10),
                  child: _isResendEmailLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : InkWell(
                          onTap: _resendEmailVerification,
                          child: const Text('Resend Verification Email',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                        ),
                ),
              ),
            ),
          ],
        ),

        // ElevatedButton(style: ButtonStyle(
        //   backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
        //   padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        //   shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        // ),
        //   onPressed: _checkEmailVerificationStatus,
        //   child: const Text('I have verified, continue'),
        // ),
        // ElevatedButton(style: ButtonStyle(
        //   backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
        //   padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        //   shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        // ),
        //   onPressed: _resendEmailVerification,
        //   child: const Text('Resend Verification Email'),
        // ),
        Text(
          _message,
          style: const TextStyle(
            color: Colors.teal,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerificationUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              hintText: 'OTP'),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
          ),
          onPressed: _isVerifyLoading ? null : _handleOtpVerification,
          child: _isVerifyLoading
              ? const CircularProgressIndicator()
              : const Text('Verify OTP'),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
          ),
          onPressed: _isResendOtpLoadin ? null : _resendOtp,
          child: _isResendOtpLoadin
              ? const CircularProgressIndicator()
              : const Text('Resend OTP'),
        ),
        Text(_message,
            style: const TextStyle(color: Colors.teal, fontSize: 16)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3) PHONE VERIFICATION UI (Enter SMS code)
  // ---------------------------------------------------------------------------
  // Widget _buildPhoneVerificationUI() {
  //   return Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       Text(
  //         _verificationId == null
  //             ? 'Sending verification code to your phone...'
  //             : 'Enter the SMS verification code below:',
  //       ),
  //       if (_verificationId != null)
  //         TextField(
  //           controller: _smsCodeController,
  //           decoration: const InputDecoration(labelText: 'SMS Code'),
  //         ),
  //       ElevatedButton(style: ButtonStyle(
  //   backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
  //   padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
  //   shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
  // ),
  //         onPressed:
  //             _verificationId == null ? null : _handlePhoneVerificationCode,
  //         child: const Text('Verify Phone'),
  //       ),
  //       Text(
  //         _message,
  //         style: const TextStyle(
  //           color: Colors.teal,
  //           fontSize: 16,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ---------------------------------------------------------------------------
  // 4) SUCCESS SCREEN
  // ---------------------------------------------------------------------------
  Widget _buildSuccessScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 25,
      children: [
        const Text(
          'Your account is verified! Registration complete.',
          style: TextStyle(color: Colors.green),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
          ),
          onPressed: () {
            // Navigate to your admin dashboard or anywhere else.
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => DashboardPage()));
          },
          child: const Text('Go to Dashboard'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HANDLERS
  // ---------------------------------------------------------------------------
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final pass = _passwordController.text;

    setState(() {
      _message = '';
      _isSignUpLoading = true;
    });

    try {
      if (_selectedMethod == VerificationMethod.email) {
        // Create user with email verification.
        await _authService.createUserWithEmailVerification(
          fullName: fullName,
          email: email,
          password: pass,
        );
        setState(() {
          _isRegistered = true;
          _currentStep = RegistrationStep.emailVerification;
          _message =
              'Sign-up successful. Check your email for a verification link.';
        });
      } else {
        // Create user normally and store extra data in Firestore.
        // UserCredential userCredential =
        //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
        //   email: email,
        //   password: pass,
        // );
        // final uid = userCredential.user?.uid;
        // if (uid != null) {
        //   await FirebaseFirestore.instance.collection('admins').doc(uid).set({
        //     'fullName': fullName,
        //     'email': email,
        //     'phone': phone,
        //     'createdAt': DateTime.now(),
        //     'emailVerified': false,
        //     'phoneVerified': false,
        //   });
        // }
        // // Initiate phone verification.
        // final verificationId = await _authService.verifyPhoneNumber(phone);
        // setState(() {
        //   _verificationId = verificationId;
        //   _isRegistered = true;
        //   _message = 'Enter the SMS code you received.';
        // });
      }
    } catch (e) {
      setState(() => _message = 'Sign-up failed: $e');
    } finally {
      setState(() {
        _isSignUpLoading = false;
      });
    }
  }

  Future<void> _checkEmailVerificationStatus() async {
    setState(() {
      _isEmailVerificationLoading = true;
      _message = '';
    });
    try {
      bool isVerified = await _authService.checkEmailVerification();
      if (isVerified) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(user.uid)
              .update({'emailVerified': true});
          final otp = _authService.generateOtp();
          // await _authService.storeOtp(user.uid, otp);
          await _authService.sendOtpEmail(user.email!, otp);
          setState(() {
            _currentStep = RegistrationStep.otpVerification;
            _message = 'OTP sent to your email. Please enter it to continue.';
          });
        }
      } else {
        setState(() {
          _message = 'Your email is not verified yet. Check your inbox.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error checking verification: $e';
      });
    } finally {
      setState(() {
        _isEmailVerificationLoading = false;
      });
    }
  }

  Future<void> _resendEmailVerification() async {
    setState(() {
      _isResendEmailLoading = true;
      _message = '';
    });
    try {
      await _authService.resendVerificationEmail();
      setState(() {
        _message = 'Verification email resent. Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to resend email: $e';
      });
    } finally {
      setState(() {
        _isResendEmailLoading = false;
      });
    }
  }

  // Future<void> _handlePhoneVerificationCode() async {
  //   setState(() {
  //     // _isSignUpLoading = true;
  //     _message = '';
  //   });
  //   if (_verificationId == null) {
  //     setState(() => _message = 'No verificationId. Try again.');
  //     return;
  //   }
  //   if (_smsCodeController.text.isEmpty) {
  //     setState(() => _message = 'Please enter the SMS code.');
  //     return;
  //   }
  //   try {
  //     await _authService.signInWithSmsCode(
  //       _verificationId!,
  //       _smsCodeController.text.trim(),
  //     );
  //     await _authService.updatePhoneVerified();
  //     setState(() {
  //       _isVerified = true;
  //       _message = 'Phone number verified!';
  //     });
  //   } catch (e) {
  //     setState(() => _message = 'Failed to verify phone: $e');
  //   }
  // }
  Future<void> _handleOtpVerification() async {
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
          setState(() {
            _currentStep = RegistrationStep.complete;
            _message = 'OTP verified! Registration complete.';
          });
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
      _isResendOtpLoadin = true;
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
      setState(() => _isResendOtpLoadin = false);
    }
  }
}
