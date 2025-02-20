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

  final AuthService _authService = AuthService();

  VerificationMethod _verificationMethod = VerificationMethod.email;

  // For phone verification
  String? _verificationId;
  final _smsCodeController = TextEditingController();

  // For UI feedback
  bool _isRegistered = false;
  bool _isVerified = false;
  String _message = '';

  var _obscureConfirmPassword = true;

  var _obscurePassword = true;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildContent() {
    // If not yet registered, show the sign-up form.
    if (!_isRegistered) {
      return _buildSignUpForm();
    }

    // If registered but not verified.
    if (!_isVerified) {
      if (_verificationMethod == VerificationMethod.email) {
        return _buildEmailVerificationWait();
      } else {
        return _buildPhoneVerificationUI();
      }
    }

    // If user is verified.
    return _buildSuccessScreen();
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
          const SizedBox(height: 15),
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
                      color: Colors.black)),
            ),
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
                groupValue: _verificationMethod,
                onChanged: (val) {
                  setState(() => _verificationMethod = val!);
                },
              ),
              const Text('Verify by Email'),
              const SizedBox(width: 20),
              Radio<VerificationMethod>(
                value: VerificationMethod.phone,
                groupValue: _verificationMethod,
                onChanged: (val) {
                  setState(() => _verificationMethod = val!);
                },
              ),
              const Text('Verify by Phone (SMS)'),
            ],
          ),

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
                  onTap: _handleSignUp,
                  child: const Text('Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white)),
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
                      // Navigate to the login screen.
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
      children: [
        const Text(
          'A verification link has been sent to your email. Please verify.',
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
          onPressed: _checkEmailVerificationStatus,
          child: const Text('I have verified, continue'),
        ),
        ElevatedButton(
          onPressed: _resendEmailVerification,
          child: const Text('Resend Verification Email'),
        ),
        Text(_message, style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3) PHONE VERIFICATION UI (Enter SMS code)
  // ---------------------------------------------------------------------------
  Widget _buildPhoneVerificationUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _verificationId == null
              ? 'Sending verification code to your phone...'
              : 'Enter the SMS verification code below:',
        ),
        if (_verificationId != null)
          TextField(
            controller: _smsCodeController,
            decoration: const InputDecoration(labelText: 'SMS Code'),
          ),
        ElevatedButton(
          onPressed:
              _verificationId == null ? null : _handlePhoneVerificationCode,
          child: const Text('Verify Phone'),
        ),
        Text(_message, style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4) SUCCESS SCREEN
  // ---------------------------------------------------------------------------
  Widget _buildSuccessScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Your account is verified! Registration complete.',
          style: TextStyle(color: Colors.green),
        ),
        ElevatedButton(
          onPressed: () {
            // Navigate to your admin dashboard or anywhere else.
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

    setState(() => _message = '');

    try {
      if (_verificationMethod == VerificationMethod.email) {
        // Create user with email verification.
        await _authService.createUserWithEmailVerification(
          fullName: fullName,
          email: email,
          password: pass,
        );
        setState(() {
          _isRegistered = true;
          _message =
              'Sign-up successful. Check your email for a verification link.';
        });
      } else {
        // Create user normally and store extra data in Firestore.
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );
        final uid = userCredential.user?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection('admins').doc(uid).set({
            'fullName': fullName,
            'email': email,
            'phone': phone,
            'createdAt': DateTime.now(),
            'emailVerified': false,
            'phoneVerified': false,
          });
        }
        // Initiate phone verification.
        final verificationId = await _authService.verifyPhoneNumber(phone);
        setState(() {
          _verificationId = verificationId;
          _isRegistered = true;
          _message = 'Enter the SMS code you received.';
        });
      }
    } catch (e) {
      setState(() => _message = 'Sign-up failed: $e');
    }
  }

  Future<void> _checkEmailVerificationStatus() async {
    try {
      bool isVerified = await _authService.checkEmailVerification();
      if (isVerified) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(user.uid)
              .update({'emailVerified': true});
        }
        setState(() {
          _isVerified = true;
          _message = 'Email verified!';
        });
      } else {
        setState(() {
          _message = 'Your email is not verified yet. Check your inbox.';
        });
      }
    } catch (e) {
      setState(() => _message = 'Error checking verification: $e');
    }
  }

  Future<void> _resendEmailVerification() async {
    try {
      await _authService.resendVerificationEmail();
      setState(() => _message = 'Verification email resent. Check your inbox.');
    } catch (e) {
      setState(() => _message = 'Failed to resend email: $e');
    }
  }

  Future<void> _handlePhoneVerificationCode() async {
    setState(() => _message = '');
    if (_verificationId == null) {
      setState(() => _message = 'No verificationId. Try again.');
      return;
    }
    if (_smsCodeController.text.isEmpty) {
      setState(() => _message = 'Please enter the SMS code.');
      return;
    }
    try {
      await _authService.signInWithSmsCode(
        _verificationId!,
        _smsCodeController.text.trim(),
      );
      await _authService.updatePhoneVerified();
      setState(() {
        _isVerified = true;
        _message = 'Phone number verified!';
      });
    } catch (e) {
      setState(() => _message = 'Failed to verify phone: $e');
    }
  }
}
