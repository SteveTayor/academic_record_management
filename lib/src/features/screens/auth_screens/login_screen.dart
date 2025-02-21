import 'package:archival_system/src/features/screens/auth_screens/admin_signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/service/firebase_services.dart';
import '../dashborad/dashboard.dart';
import 'validation.dart'; // Adjust path accordingly

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for email, password, and SMS code inputs.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _smsCodeController = TextEditingController();
  final _resetEmailController = TextEditingController();
  // Instance of our AuthService.
  final AuthService _authService = AuthService();

  // MFA-related state.
  MultiFactorResolver? _mfaResolver;
  String? _verificationId;

  // Message for status and errors.
  String _message = '';

  var _obscurePassword = true;

  bool _isLoading = false;

  Future<void> _showForgotPasswordDialog() async {
    String dialogMessage = '';
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _resetEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.blueGrey.shade50,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (dialogMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dialogMessage,
                        style: TextStyle(
                          color: dialogMessage.contains('sent')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _resetEmailController.clear();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_resetEmailController.text.trim().isEmpty) {
                            setState(() {
                              dialogMessage = 'Please enter your email address';
                            });
                            return;
                          }

                          setState(() {
                            isLoading = true;
                            dialogMessage = '';
                          });

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _resetEmailController.text.trim(),
                            );
                            setState(() {
                              dialogMessage =
                                  'Password reset link sent! Check your email.';
                            });
                            await Future.delayed(const Duration(seconds: 2));
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            _resetEmailController.clear();
                          } catch (e) {
                            setState(() {
                              dialogMessage = 'Error: ${e.toString()}';
                            });
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Send Reset Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 15,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.lightBlue.withOpacity(.2),
                              child: Icon(Icons.lock_outline_rounded,
                                  size: 25, color: Colors.blue.shade600),
                            ),
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your credentials to access your account.',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blueGrey.shade300,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 15,
                          children: [
                            const SizedBox(height: 12),
                            const Text('Email',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            TextFormField(
                              controller: _emailController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                fillColor: Colors.blueGrey.shade50,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey.shade50),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey.shade50),
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
                              //   if (!value.isValidEmail)
                              //     'Enter a valid email address.';
                              // },
                              validator: (value) {
                                if (value.isNullOrEmpty)
                                  return 'Email is required.';
                                if (!value.isValidEmail)
                                  return 'Enter a valid email address.';
                                return null;
                              }, // ElevatedButton(
                              //   onPressed: () {
                              //     // Navigate to your admin dashboard or anywhere else.
                              //   },
                              //   child: const Text('Go to Dashboard'),
                              // ),
                            ),
                            const Text('Password',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                fillColor: Colors.blueGrey.shade50,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey.shade50),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey.shade50),
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
                              //   if (value.isNullOrEmpty)
                              //     'Password is required.';

                              // },
                              validator: (value) {
                                if (value.isNullOrEmpty)
                                  return 'Password is required.';

                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // Continue button (disabled if MFA is triggered).

                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  backgroundBlendMode: BlendMode.darken,
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.blue.shade800,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: _mfaResolver == null
                                        ? _handleLogin
                                        : null,
                                    child: const Text(
                                      'Continue',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 24),
                            // Conditionally show the MFA UI if a resolver is available.
                            if (_mfaResolver != null) ...[
                              const Text(
                                  'Multi-Factor Authentication Required'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _smsCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter SMS Code',
                                  prefixIcon: Icon(Icons.sms),
                                ),
                                validator: (value) {
                                  if (value.isNullOrEmpty)
                                    return 'SMS code is required';
                                  return null;
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: .0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    backgroundBlendMode: BlendMode.darken,
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.blue.shade800,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: _finalizeMfaSignIn,
                                            child: const Text('Verify SMS Code',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white)),
                                          ), // ElevatedButton(
                                    //   onPressed: () {
                                    //     // Navigate to your admin dashboard or anywhere else.
                                    //   },
                                    //   child: const Text('Go to Dashboard'),
                                    // ),
                                  ),
                                ),
                              ),
                              // ElevatedButton(
                              //   onPressed: _finalizeMfaSignIn,
                              //   child: const Text('Verify SMS Code'),
                              // ),
                            ],

                            Center(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Don\'t have an account? ',
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Sign up', // ElevatedButton(
                                      //   onPressed: () {
                                      //     // Navigate to your admin dashboard or anywhere else.
                                      //   },
                                      //   child: const Text('Go to Dashboard'),
                                      // ),
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade400,
                                          fontWeight: FontWeight.w500),
                                      // Add navigation to the sign-up screen.
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = ()
                                            // Navigate to the login screen.
                                            =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      AdminRegistrationPage()),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                    // Email input.

                    // Display status or error messages.
                    Text(
                      _message,
                      style: TextStyle(color: Colors.teal),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles sign in with email/password.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _message = '';
      _isLoading = true;
    });
    try {
      // Attempt to sign in normally.
      await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      setState(() {
        _message = 'Login successful!';
      });
       _navigateToDashboard();
    } on FirebaseAuthMultiFactorException catch (e) {
      // MFA is required. Save the resolver and start phone verification.
      setState(() {
        _mfaResolver = e.resolver;
        _message = 'MFA required. Sending SMS code...';
      });
      await _startMfaPhoneVerification(e.resolver);
    } catch (e) {
      setState(() {
        _message = 'Login failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Initiates the phone verification for MFA.
  Future<void> _startMfaPhoneVerification(MultiFactorResolver resolver) async {
    if (resolver.hints.isNotEmpty) {
      // Assume the first enrolled factor is the phone factor.
      final factorInfo = resolver.hints.first;
      if (factorInfo is PhoneMultiFactorInfo) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          multiFactorSession: resolver.session,
          phoneNumber: factorInfo.phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto-retrieval: complete MFA automatically.
            final assertion =
                PhoneMultiFactorGenerator.getAssertion(credential);
            await resolver.resolveSignIn(assertion);
            setState(() {
              _message = 'MFA completed via auto-verification.';
              _mfaResolver = null;
            });
          },
          verificationFailed: (FirebaseAuthException error) {
            setState(() {
              _message = 'MFA phone verification failed: ${error.message}';
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
              _message = 'SMS code sent. Please check your phone.';
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() {
              _verificationId = verificationId;
            });
          },
        );
      }
    }
  }

  /// Finalizes the MFA sign-in using the SMS code entered by the user.
  Future<void> _finalizeMfaSignIn() async {
    if (_mfaResolver == null || _verificationId == null) {
      setState(() {
        _message = 'Verification details are missing.';
      });
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final smsCode = _smsCodeController.text.trim();
    if (smsCode.isEmpty) {
      setState(() {
        _message = 'Please enter the SMS code.';
        _isLoading = true;
      });
      return;
    }
    try {
      await _authService.finalizeMultiFactorSignIn(
        resolver: _mfaResolver!,
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      setState(() {
        _message = 'MFA complete! You are now logged in.';
        _mfaResolver = null;
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to finalize MFA sign-in: $e';
      });
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            const DashboardPage(), // Replace with your dashboard screen
      ),
    );
  }
}
