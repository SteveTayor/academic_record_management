import 'package:archival_system/src/features/screens/auth_screens/admin_signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/service/firebase_services.dart';
import 'enum.dart';
import 'otp_verification_page.dart';
import 'validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers for inputs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _resetEmailController = TextEditingController();

  // Auth service
  final AuthService _authService = AuthService();

  // MFA-related state
  MultiFactorResolver? _mfaResolver;
  String? _verificationId;

  // UI state
  String _message = '';
  final LoginStep _currentStep = LoginStep.enterCredentials;
  var _obscurePassword = true;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // Start animation after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  // Forgot password dialog implementation
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
                  ).animate().fade(duration: 300.ms),
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
                  ).animate().slideX(
                        begin: 0.5,
                        end: 0,
                        delay: 150.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutQuad,
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
                      ).animate().fadeIn(duration: 300.ms),
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
                            await _authService.sendPasswordResetEmail(
                              _resetEmailController.text.trim(),
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
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
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
      body: Container(
        // Add a subtle background pattern
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              Colors.lightBlue.withOpacity(.2),
                                          child: Icon(
                                              Icons.lock_outline_rounded,
                                              size: 25,
                                              color: Colors.blue.shade600),
                                        ).animate().scale(
                                              delay: 300.ms,
                                              duration: 600.ms,
                                              curve: Curves.elasticOut,
                                            ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Welcome back',
                                          style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold),
                                        )
                                            .animate()
                                            .fadeIn(
                                              delay: 400.ms,
                                              duration: 800.ms,
                                            )
                                            .slideX(
                                              begin: -0.2,
                                              end: 0,
                                              delay: 400.ms,
                                              duration: 800.ms,
                                              curve: Curves.easeOutQuint,
                                            ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Enter your credentials to access your account.',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blueGrey.shade300,
                                              fontWeight: FontWeight.w500),
                                        )
                                            .animate()
                                            .fadeIn(
                                              delay: 600.ms,
                                              duration: 800.ms,
                                            )
                                            .slideX(
                                              begin: -0.2,
                                              end: 0,
                                              delay: 600.ms,
                                              duration: 800.ms,
                                              curve: Curves.easeOutQuint,
                                            ),
                                      ],
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/university-of-ibadan-logo-transparent.png',
                                    height: 80,
                                    width: 100,
                                    fit: BoxFit.contain,
                                  ).animate().scale(
                                        begin: const Offset(0.8,
                                            0.8), // non-zero values for both x and y
                                        end: const Offset(1.0, 1.0),
                                        delay: 200.ms,
                                        duration: 600.ms,
                                        curve: Curves.easeOutBack,
                                      )
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                duration: 800.ms,
                                curve: Curves.easeOut,
                              )
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                duration: 800.ms,
                                curve: Curves.easeOut,
                              ),
                          const SizedBox(height: 12),
                          Card(
                            color: Colors.white,
                            elevation: 4,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 22),
                                  const Text('Login',
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold))
                                      .animate()
                                      .fadeIn(delay: 300.ms)
                                      .slideX(
                                        begin: -0.1,
                                        end: 0,
                                        delay: 300.ms,
                                        duration: 500.ms,
                                      ),
                                  const Divider()
                                      .animate()
                                      .fadeIn(delay: 400.ms)
                                      .slideX(
                                        begin: 1.0,
                                        end: 0,
                                        delay: 400.ms,
                                        duration: 400.ms,
                                      ),
                                  const SizedBox(height: 22),

                                  // Email Field
                                  const Text('Email',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))
                                      .animate()
                                      .fadeIn(delay: 500.ms),
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return FocusScope(
                                        child: Focus(
                                          onFocusChange: (hasFocus) {
                                            setState(() {});
                                          },
                                          child: TextFormField(
                                            controller: _emailController,
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: InputDecoration(
                                              fillColor:
                                                  Colors.blueGrey.shade50,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: _emailController
                                                            .text.isNotEmpty
                                                        ? Colors.blue
                                                            .withOpacity(0.3)
                                                        : Colors
                                                            .blueGrey.shade50),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blue.shade400,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              border: InputBorder.none,
                                              hintText: 'Enter your Email',
                                              suffixIcon: const Icon(
                                                  Icons.email_outlined,
                                                  size: 15,
                                                  color: Colors.black),
                                            ),
                                            validator: (value) {
                                              if (value.isNullOrEmpty) {
                                                return 'Email is required.';
                                              }
                                              if (!value.isValidEmail) {
                                                return 'Enter a valid email address.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ).animate().fadeIn(delay: 600.ms).slideX(
                                        begin: 0.05,
                                        end: 0,
                                        delay: 600.ms,
                                        duration: 400.ms,
                                      ),

                                  const SizedBox(height: 15),

                                  // Password Field
                                  const Text('Password',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold))
                                      .animate()
                                      .fadeIn(delay: 700.ms),
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return FocusScope(
                                        child: Focus(
                                          onFocusChange: (hasFocus) {
                                            setState(() {});
                                          },
                                          child: TextFormField(
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: InputDecoration(
                                              fillColor:
                                                  Colors.blueGrey.shade50,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: _passwordController
                                                            .text.isNotEmpty
                                                        ? Colors.blue
                                                            .withOpacity(0.3)
                                                        : Colors
                                                            .blueGrey.shade50),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.blue.shade400,
                                                    width: 2),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              border: InputBorder.none,
                                              hintText: 'Password',
                                              suffixIcon: InkWell(
                                                onTap: () => setState(() =>
                                                    _obscurePassword =
                                                        !_obscurePassword),
                                                child: Icon(
                                                  _obscurePassword
                                                      ? Icons.lock_outline
                                                      : Icons.remove_red_eye,
                                                  size: 15,
                                                  color: Colors.black,
                                                )
                                                    .animate(
                                                        target: _obscurePassword
                                                            ? 0
                                                            : 1)
                                                    .rotate(duration: 300.ms),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value.isNullOrEmpty) {
                                                return 'Password is required.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ).animate().fadeIn(delay: 800.ms).slideX(
                                        begin: 0.05,
                                        end: 0,
                                        delay: 800.ms,
                                        duration: 400.ms,
                                      ),

                                  const SizedBox(height: 10),

                                  // Forgot Password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _showForgotPasswordDialog,
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue.shade800,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.blue.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ).animate().fadeIn(delay: 900.ms),
                                  ),

                                  const SizedBox(height: 20),

                                  // Login Button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade700,
                                          Colors.blue.shade900,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.shade300
                                              .withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(15),
                                        onTap: _isLoading ? null : _handleLogin,
                                        splashColor:
                                            Colors.white.withOpacity(0.2),
                                        highlightColor: Colors.transparent,
                                        child: Center(
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                                  .animate(
                                                      onPlay: (controller) =>
                                                          controller.repeat())
                                                  .scaleXY(
                                                    begin: 0.8,
                                                    end: 1.0,
                                                    duration: 600.ms,
                                                    curve: Curves.easeInOut,
                                                  )
                                              : const Text(
                                                  'Continue',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: 1000.ms).slideY(
                                        begin: 0.2,
                                        end: 0,
                                        delay: 1000.ms,
                                        duration: 500.ms,
                                        curve: Curves.easeOutQuad,
                                      ),

                                  const SizedBox(height: 20),

                                  // Sign up text
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Don\'t have an account? ',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: 'Sign up',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue.shade400,
                                                fontWeight: FontWeight.w500),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () =>
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            const AdminRegistrationPage()),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: 1100.ms),

                                  if (_message.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Text(
                                        _message,
                                        style:
                                            const TextStyle(color: Colors.red),
                                        textAlign: TextAlign.center,
                                      ).animate().fadeIn().shake(),
                                    ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(
                                delay: 300.ms,
                                duration: 800.ms,
                                curve: Curves.easeOut,
                              )
                              .slideY(
                                begin: 0.3,
                                end: 0,
                                delay: 300.ms,
                                duration: 800.ms,
                                curve: Curves.easeOutQuad,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles sign in with email/password with animated feedback
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      // Shake the form on validation errors
      setState(() {
        _message = 'Please check the form fields';
      });
      return;
    }

    setState(() {
      _message = '';
      _isLoading = true;
    });

    try {
      // Attempt to sign in
      final user = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // Reset OTP verification status
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .update({'otpVerified': false});

        final otp = _authService.generateOtp();
        await _authService.storeOtp(user.uid, otp);
        await _authService.sendOtpEmail(user.email!, otp);

        // Navigate to OTP verification page with a transition animation
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OtpVerificationPage(email: user.email!),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutQuart;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
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
}
