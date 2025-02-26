// import 'package:archival_system/src/features/screens/dashborad/dashboard.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../core/service/firebase_services.dart';
// import 'enum.dart';
// import 'login_screen.dart';
// import 'validation.dart';

// class AdminRegistrationPage extends StatefulWidget {
//   const AdminRegistrationPage({Key? key}) : super(key: key);

//   @override
//   _AdminRegistrationPageState createState() => _AdminRegistrationPageState();
// }

// class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _otpController = TextEditingController();

//   final AuthService _authService = AuthService();

//   RegistrationStep _currentStep = RegistrationStep.signUp;
//   VerificationMethod? _selectedMethod = VerificationMethod.email;

//   // For phone verification
//   String? _verificationId;
//   final _smsCodeController = TextEditingController();

//   // For UI feedback
//   bool _isRegistered = false;
//   bool _isVerified = false;
//   String _message = '';

//   bool _obscureConfirmPassword = true;

//   bool _obscurePassword = true;

//   bool _isSignUpLoading = false;
//   bool _isResendEmailLoading = false;
//   bool _isLoading = false;
//   bool _isOtpSentLoading = false;
//   bool _isVerifyLoading = false;
//   bool _isResendOtpLoadin = false;
//   bool _isEmailVerificationLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 30),
//             child: Column(
//               spacing: 18,
//               children: [
//                 Container(
//                   width: 470,
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.blueGrey.shade50,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           spacing: 8,
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Colors.lightBlue.withOpacity(.2),
//                               child: Icon(Icons.safety_check_sharp,
//                                   size: 25, color: Colors.blue.shade600),
//                             ),
//                             const Text(
//                               'UniVault Admin Registration',
//                               style: TextStyle(
//                                   fontSize: 28, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'Secure registration for approved administrators',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.blueGrey.shade300,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Image.asset(
//                         'assets/images/university-of-ibadan-logo-transparent.png',
//                         height: 80,
//                         width: 100,
//                         fit: BoxFit.fitHeight,
//                       )
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   width: 500,
//                   child: Card(
//                     color: Colors.white,
//                     margin: const EdgeInsets.all(16),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 16, horizontal: 25),
//                       child: _buildContent(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _buildContent() {
//   //   // If not yet registered, show the sign-up form.
//   //   if (!_isRegistered) {
//   //     return _buildSignUpForm();
//   //   }

//   //   // If registered but not verified.
//   //   if (!_isVerified) {
//   //     if (_selectedMethod == VerificationMethod.email) {
//   //       return _buildEmailVerificationWait();
//   //     } else {
//   //       return _buildPhoneVerificationUI();
//   //     }
//   //   }

//   //   // If user is verified.
//   //   return _buildSuccessScreen();
//   // }
//   Widget _buildContent() {
//     switch (_currentStep) {
//       case RegistrationStep.signUp:
//         return _buildSignUpForm();
//       case RegistrationStep.emailVerification:
//         return _buildEmailVerificationWait();
//       case RegistrationStep.otpVerification:
//         return _buildOtpVerificationUI();
//       case RegistrationStep.complete:
//         return _buildSuccessScreen();
//     }
//   }

//   // ---------------------------------------------------------------------------
//   // 1) SIGN-UP FORM (with complex validation)
//   // ---------------------------------------------------------------------------
//   Widget _buildSignUpForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         spacing: 8,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Sign Up',
//               style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
//           Divider(
//             color: Colors.grey.withOpacity(.3),
//           ),
//           const SizedBox(height: 25),
//           const Text('Full Name',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

//           TextFormField(
//             controller: _fullNameController,
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               fillColor: Colors.blueGrey.shade50,
//               filled: true,
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               border: InputBorder.none,
//               suffixIcon: const Icon(Icons.person_outline_outlined,
//                   size: 15, color: Colors.black),
//               hintText: 'Enter your Full Name',
//             ),
//             // onChanged: (value) {
//             //   setState(() {
//             //     _fullNameController.text = value;
//             //   });
//             //   if (value.isNullOrEmpty) 'Full Name is required.';
//             //   if (!value.isValidName) 'Enter a valid name.';
//             //   return null;
//             // },
//             validator: (value) {
//               if (value.isNullOrEmpty) return 'Full Name is required.';
//               if (!value.isValidName) return 'Enter a valid name.';
//               return null;
//             },
//           ),

//           const Text('Email',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

//           TextFormField(
//             controller: _emailController,
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               fillColor: Colors.blueGrey.shade50,
//               filled: true,
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               border: InputBorder.none,
//               hintText: 'Enter your Email',
//               suffixIcon: const Icon(Icons.email_outlined,
//                   size: 15, color: Colors.black),
//             ),
//             // onChanged: (value) {
//             //   setState(() {
//             //     _emailController.text = value;
//             //   });
//             //   if (value.isNullOrEmpty) 'Email is required.';
//             //   if (!value.isValidEmail) 'Enter a valid email address.';
//             //   return null;
//             // },
//             validator: (value) {
//               if (value.isNullOrEmpty) return 'Email is required.';
//               if (!value.isValidEmail) return 'Enter a valid email address.';
//               return null;
//             },
//           ),

//           const Text('Phone number',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

//           TextFormField(
//             controller: _phoneController,
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               fillColor: Colors.blueGrey.shade50,
//               filled: true,
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               border: InputBorder.none,
//               hintText: 'Enter your Phone Number',
//               suffixIcon: const Icon(Icons.phone_enabled_outlined,
//                   size: 15, color: Colors.black),
//             ),
//             // onChanged: (value) {
//             //   setState(() {
//             //     _phoneController.text = value;
//             //   });
//             //   if (value.isNullOrEmpty) 'Phone number is required.';
//             //   if (!value.isValidPhone) 'Enter a valid phone number.';
//             //   return null;
//             // },
//             validator: (value) {
//               if (value.isNullOrEmpty) return 'Phone number is required.';
//               if (!value.isValidPhone) return 'Enter a valid phone number.';
//               return null;
//             },
//           ),

//           const Text('Password',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

//           TextFormField(
//             controller: _passwordController,
//             obscureText: _obscurePassword,
//             textInputAction: TextInputAction.next,
//             decoration: InputDecoration(
//               fillColor: Colors.blueGrey.shade50,
//               filled: true,
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               border: InputBorder.none,
//               hintText: 'Password',
//               suffixIcon: InkWell(
//                 onTap: () {
//                   setState(() {
//                     _obscurePassword = !_obscurePassword;
//                   });
//                 },
//                 child: Icon(
//                   _obscurePassword == true
//                       ? Icons.lock_outline
//                       : Icons.remove_red_eye,
//                   size: 15,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             // onChanged: (value) {
//             //   setState(() {
//             //     _passwordController.text = value;
//             //   });
//             //   if (value.isNullOrEmpty) 'Password is required.';
//             //   if (!value.isValidPassword) {
//             //     'Password must be at least 8 characters and include uppercase, lowercase, digit, and special character.';
//             //   }
//             //   return null;
//             // },
//             validator: (value) {
//               if (value.isNullOrEmpty) return 'Password is required.';
//               if (!value.isValidPassword) {
//                 return 'Password must be at least 8 characters and include uppercase, lowercase, digit, and special character.';
//               }
//               return null;
//             },
//           ),

//           const Text('Confirm Password',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

//           TextFormField(
//             controller: _confirmPasswordController,
//             obscureText: _obscureConfirmPassword,
//             textInputAction: TextInputAction.done,
//             decoration: InputDecoration(
//               fillColor: Colors.blueGrey.shade50,
//               filled: true,
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               border: InputBorder.none,
//               hintText: 'Confirm Password',
//               suffixIcon: InkWell(
//                 onTap: () {
//                   setState(() {
//                     _obscureConfirmPassword = !_obscureConfirmPassword;
//                   });
//                 },
//                 child: Icon(
//                   _obscureConfirmPassword
//                       ? Icons.lock_outline
//                       : Icons.remove_red_eye,
//                   size: 15,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             // onChanged: (value) {
//             //   setState(() {
//             //     _confirmPasswordController.text = value;
//             //   });
//             //   if (value.isNullOrEmpty) 'Please confirm your password.';
//             //   if (!value.isPasswordMatch(_passwordController.text)) {
//             //     'Passwords do not match.';
//             //   }
//             //   return null;
//             // },
//             validator: (String? value) {
//               if (value!.isNullOrEmpty) return 'Please confirm your password.';
//               if (!value.isPasswordMatch(_passwordController.text)) {
//                 return 'Passwords do not match.';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 10),
//           // Radio Buttons: Choose verification method.
//           Row(
//             children: [
//               Radio<VerificationMethod>(
//                 value: VerificationMethod.email,
//                 groupValue: _selectedMethod,
//                 onChanged: (val) {
//                   setState(() => _selectedMethod = val!);
//                 },
//               ),
//               const Text('Verify by Email'),
//               // const SizedBox(width: 20),
//               // Radio<VerificationMethod>(
//               //   value: VerificationMethod.phone,
//               //   groupValue: _selectedMethod,
//               //   onChanged: (val) {
//               //     setState(() => _selectedMethod = val!);
//               //   },
//               // ),
//               // const Text('Verify by Phone (SMS)'),
//             ],
//           ),

//           Padding(
//             padding: const EdgeInsets.only(top: 15.0),
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 backgroundBlendMode: BlendMode.darken,
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.blue.shade800,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: _isSignUpLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : InkWell(
//                         onTap: _handleSignUp,
//                         child: const Text('Sign Up',
//                             textAlign: TextAlign.center,
//                             style:
//                                 TextStyle(fontSize: 18, color: Colors.white)),
//                       ),
//               ),
//             ),
//           ),
//           Center(
//             child: RichText(
//                 text: TextSpan(
//               text: 'Already have an account? ',
//               style: TextStyle(color: Colors.black, fontSize: 14),
//               children: [
//                 TextSpan(
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = () {
//                       // Navigate to the login screen.redred
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => LoginPage()));
//                     },
//                   text: ' Login',
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.blue.shade400,
//                       fontWeight: FontWeight.w500),
//                 ),
//               ],
//             )),
//           ),

//           Text(
//             _message,
//             style: const TextStyle(color: Colors.red),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // 2) WAITING FOR EMAIL VERIFICATION
//   // ---------------------------------------------------------------------------
//   Widget _buildEmailVerificationWait() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       spacing: 25,
//       children: [
//         const Text(
//           'A verification link has been sent to your email. Please verify.',
//           textAlign: TextAlign.center,
//         ),

//         Row(
//           children: [
//             Container(
//               width: 150,
//               decoration: BoxDecoration(
//                 backgroundBlendMode: BlendMode.darken,
//                 borderRadius: BorderRadius.circular(15),
//                 color: Colors.blue.shade800,
//               ),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
//                 child: _isEmailVerificationLoading
//                     ? const Center(
//                         child: CircularProgressIndicator(
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : InkWell(
//                         onTap: _checkEmailVerificationStatus,
//                         child: Flexible(
//                           child: const Text('I have verified, continue',
//                               textAlign: TextAlign.center,
//                               style:
//                                   TextStyle(fontSize: 14, color: Colors.white)),
//                         ),
//                       ),
//               ),
//             ),
//             SizedBox(
//               width: 30,
//             ),
//             Expanded(
//               child: Container(
//                 width: 150,
//                 decoration: BoxDecoration(
//                   backgroundBlendMode: BlendMode.darken,
//                   borderRadius: BorderRadius.circular(15),
//                   color: Colors.blue.shade800,
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 15.0, vertical: 10),
//                   child: _isResendEmailLoading
//                       ? const Center(
//                           child: CircularProgressIndicator(
//                             valueColor:
//                                 AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         )
//                       : InkWell(
//                           onTap: _resendEmailVerification,
//                           child: const Text('Resend Verification Email',
//                               textAlign: TextAlign.center,
//                               style:
//                                   TextStyle(fontSize: 14, color: Colors.white)),
//                         ),
//                 ),
//               ),
//             ),
//           ],
//         ),

//         // ElevatedButton(style: ButtonStyle(
//         //   backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
//         //   padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
//         //   shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//         // ),
//         //   onPressed: _checkEmailVerificationStatus,
//         //   child: const Text('I have verified, continue'),
//         // ),
//         // ElevatedButton(style: ButtonStyle(
//         //   backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
//         //   padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
//         //   shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//         // ),
//         //   onPressed: _resendEmailVerification,
//         //   child: const Text('Resend Verification Email'),
//         // ),
//         Text(
//           _message,
//           style: const TextStyle(
//             color: Colors.teal,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOtpVerificationUI() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       spacing: 10,
//       children: [
//         SizedBox(height: 10),
//         const Text(
//           'Verify Otp.',
//           style: TextStyle(
//             fontSize: 30,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(
//           height: 15,
//         ),
//         const Text('Enter the OTP sent to your email:'),
//         TextField(
//           controller: _otpController,
//           decoration: InputDecoration(
//               fillColor: Colors.blueGrey.shade50,
//               filled: true,
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.blueGrey.shade50),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               border: InputBorder.none,
//               hintText: 'OTP'),
//         ),
//         Center(
//           child: RichText(
//             text: TextSpan(
//               text: 'Didn\'t receive any code? ',
//               style: const TextStyle(color: Colors.black),
//               children: [
//                 TextSpan(
//                   text: 'Resend',
//                   style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.blue.shade600,
//                       fontWeight: FontWeight.w500),
//                   recognizer: TapGestureRecognizer()
//                     ..onTap = _isResendOtpLoadin ? null : _resendOtp,
//                 ),
//               ],
//             ),
//           ),
//         ),
//         SizedBox(
//           height: 8,
//         ),
//         ElevatedButton(
//           style: ButtonStyle(
//             backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
//             padding: WidgetStatePropertyAll(
//                 EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
//             shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15))),
//           ),
//           onPressed: _isVerifyLoading ? null : _handleOtpVerification,
//           child: _isVerifyLoading
//               ? const CircularProgressIndicator()
//               : const Text('Verify OTP'),
//         ),
//         // ElevatedButton(
//         //   style: ButtonStyle(
//         //     backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
//         //     padding: WidgetStatePropertyAll(
//         //         EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
//         //     shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//         //         borderRadius: BorderRadius.circular(15))),
//         //   ),
//         //   onPressed: _isResendOtpLoadin ? null : _resendOtp,
//         //   child: _isResendOtpLoadin
//         //       ? const CircularProgressIndicator()
//         //       : const Text('Resend OTP'),
//         // ),
//         Text(_message,
//             style: const TextStyle(color: Colors.teal, fontSize: 16)),
//       ],
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // 3) PHONE VERIFICATION UI (Enter SMS code)
//   // ---------------------------------------------------------------------------
//   // Widget _buildPhoneVerificationUI() {
//   //   return Column(
//   //     mainAxisSize: MainAxisSize.min,
//   //     children: [
//   //       Text(
//   //         _verificationId == null
//   //             ? 'Sending verification code to your phone...'
//   //             : 'Enter the SMS verification code below:',
//   //       ),
//   //       if (_verificationId != null)
//   //         TextField(
//   //           controller: _smsCodeController,
//   //           decoration: const InputDecoration(labelText: 'SMS Code'),
//   //         ),
//   //       ElevatedButton(style: ButtonStyle(
//   //   backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
//   //   padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
//   //   shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
//   // ),
//   //         onPressed:
//   //             _verificationId == null ? null : _handlePhoneVerificationCode,
//   //         child: const Text('Verify Phone'),
//   //       ),
//   //       Text(
//   //         _message,
//   //         style: const TextStyle(
//   //           color: Colors.teal,
//   //           fontSize: 16,
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // ---------------------------------------------------------------------------
//   // 4) SUCCESS SCREEN
//   // ---------------------------------------------------------------------------
//   Widget _buildSuccessScreen() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       spacing: 25,
//       children: [
//         const Text(
//           'Your account is verified! Registration complete.',
//           style: TextStyle(color: Colors.green),
//         ),
//         ElevatedButton(
//           style: ButtonStyle(
//             backgroundColor: WidgetStatePropertyAll(Colors.blue.shade800),
//             padding: WidgetStatePropertyAll(
//                 EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
//             shape: WidgetStatePropertyAll(RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15))),
//           ),
//           onPressed: () {
//             // Navigate to your admin dashboard or anywhere else.
//             Navigator.pushReplacement(context,
//                 MaterialPageRoute(builder: (context) => DashboardPage()));
//           },
//           child: const Text('Go to Dashboard'),
//         ),
//       ],
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // HANDLERS
//   // ---------------------------------------------------------------------------
//   Future<void> _handleSignUp() async {
//     if (!_formKey.currentState!.validate()) return;

//     final fullName = _fullNameController.text.trim();
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     final pass = _passwordController.text;

//     setState(() {
//       _message = '';
//       _isSignUpLoading = true;
//     });

//     try {
//       if (_selectedMethod == VerificationMethod.email) {
//         // Create user with email verification.
//         await _authService.createUserWithEmailVerification(
//           fullName: fullName,
//           email: email,
//           password: pass,
//         );
//         setState(() {
//           _isRegistered = true;
//           _currentStep = RegistrationStep.emailVerification;
//           _message =
//               'Sign-up successful. Check your email for a verification link.';
//         });
//       } else {
//         // Create user normally and store extra data in Firestore.
//         // UserCredential userCredential =
//         //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         //   email: email,
//         //   password: pass,
//         // );
//         // final uid = userCredential.user?.uid;
//         // if (uid != null) {
//         //   await FirebaseFirestore.instance.collection('admins').doc(uid).set({
//         //     'fullName': fullName,
//         //     'email': email,
//         //     'phone': phone,
//         //     'createdAt': DateTime.now(),
//         //     'emailVerified': false,
//         //     'phoneVerified': false,
//         //   });
//         // }
//         // // Initiate phone verification.
//         // final verificationId = await _authService.verifyPhoneNumber(phone);
//         // setState(() {
//         //   _verificationId = verificationId;
//         //   _isRegistered = true;
//         //   _message = 'Enter the SMS code you received.';
//         // });
//       }
//     } catch (e) {
//       setState(() => _message = 'Sign-up failed: $e');
//     } finally {
//       setState(() {
//         _isSignUpLoading = false;
//       });
//     }
//   }

//   Future<void> _checkEmailVerificationStatus() async {
//     setState(() {
//       _isEmailVerificationLoading = true;
//       _message = '';
//     });
//     try {
//       bool isVerified = await _authService.checkEmailVerification();
//       if (isVerified) {
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           await FirebaseFirestore.instance
//               .collection('admins')
//               .doc(user.uid)
//               .update({'emailVerified': true});
//           final otp = _authService.generateOtp();
//           // await _authService.storeOtp(user.uid, otp);
//           await _authService.sendOtpEmail(user.email!, otp);
//           setState(() {
//             _currentStep = RegistrationStep.otpVerification;
//             _message = 'OTP sent to your email. Please enter it to continue.';
//           });
//         }
//       } else {
//         setState(() {
//           _message = 'Your email is not verified yet. Check your inbox.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _message = 'Error checking verification: $e';
//       });
//     } finally {
//       setState(() {
//         _isEmailVerificationLoading = false;
//       });
//     }
//   }

//   Future<void> _resendEmailVerification() async {
//     setState(() {
//       _isResendEmailLoading = true;
//       _message = '';
//     });
//     try {
//       await _authService.resendVerificationEmail();
//       setState(() {
//         _message = 'Verification email resent. Check your inbox.';
//       });
//     } catch (e) {
//       setState(() {
//         _message = 'Failed to resend email: $e';
//       });
//     } finally {
//       setState(() {
//         _isResendEmailLoading = false;
//       });
//     }
//   }

//   // Future<void> _handlePhoneVerificationCode() async {
//   //   setState(() {
//   //     // _isSignUpLoading = true;
//   //     _message = '';
//   //   });
//   //   if (_verificationId == null) {
//   //     setState(() => _message = 'No verificationId. Try again.');
//   //     return;
//   //   }
//   //   if (_smsCodeController.text.isEmpty) {
//   //     setState(() => _message = 'Please enter the SMS code.');
//   //     return;
//   //   }
//   //   try {
//   //     await _authService.signInWithSmsCode(
//   //       _verificationId!,
//   //       _smsCodeController.text.trim(),
//   //     );
//   //     await _authService.updatePhoneVerified();
//   //     setState(() {
//   //       _isVerified = true;
//   //       _message = 'Phone number verified!';
//   //     });
//   //   } catch (e) {
//   //     setState(() => _message = 'Failed to verify phone: $e');
//   //   }
//   // }
//   Future<void> _handleOtpVerification() async {
//     final enteredOtp = _otpController.text.trim();
//     if (enteredOtp.isEmpty) {
//       setState(() => _message = 'Please enter the OTP.');
//       return;
//     }
//     setState(() {
//       _isVerifyLoading = true;
//       _message = '';
//     });
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         final isValid = await _authService.verifyOtp(user.uid, enteredOtp);
//         if (isValid) {
//           await _authService.markOtpVerified(user.uid);
//           setState(() {
//             _currentStep = RegistrationStep.complete;
//             _message = 'OTP verified! Registration complete.';
//           });
//         } else {
//           setState(() => _message = 'Invalid or expired OTP.');
//         }
//       }
//     } catch (e) {
//       setState(() => _message = 'Error verifying OTP: $e');
//     } finally {
//       setState(() => _isVerifyLoading = false);
//     }
//   }

//   Future<void> _resendOtp() async {
//     setState(() {
//       _isResendOtpLoadin = true;
//       _message = '';
//     });
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         // Reset OTP verification status
//         await FirebaseFirestore.instance
//             .collection('admins')
//             .doc(user.uid)
//             .update({'otpVerified': false});

//         final otp = _authService.generateOtp();
//         await _authService.storeOtp(user.uid, otp);
//         await _authService.sendOtpEmail(user.email!, otp);
//         setState(() => _message = 'OTP resent to your email.');
//       }
//     } catch (e) {
//       setState(() => _message = 'Failed to resend OTP: $e');
//     } finally {
//       setState(() => _isResendOtpLoadin = false);
//     }
//   }
// }

import 'package:archival_system/src/features/screens/dashborad/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Ensure this is in your pubspec.yaml
import 'package:lottie/lottie.dart'; // Ensure this is in your pubspec.yaml
import '../../../core/service/firebase_services.dart';
import '../../widgets/registration_stepper.dart';
import 'enum.dart';
import 'login_screen.dart';
import 'validation.dart';

class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({Key? key}) : super(key: key);

  @override
  _AdminRegistrationPageState createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _smsCodeController = TextEditingController();

  // Auth service
  final AuthService _authService = AuthService();

  // Registration and verification state
  RegistrationStep _currentStep = RegistrationStep.signUp;
  VerificationMethod? _selectedMethod = VerificationMethod.email;
  String? _verificationId; // for phone verification if needed

  // UI state flags
  bool _isRegistered = false;
  bool _isVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSignUpLoading = false;
  bool _isResendEmailLoading = false;
  bool _isLoading = false;
  bool _isOtpSentLoading = false;
  bool _isVerifyLoading = false;
  bool _isResendOtpLoadin = false;
  bool _isEmailVerificationLoading = false;
  String _message = '';

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Listen for password changes (for the strength indicator)
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Container(
                    width: 470,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Colors.lightBlue.withOpacity(.2),
                                child: Icon(Icons.safety_check_sharp,
                                    size: 25, color: Colors.blue.shade600),
                              )
                                  .animate()
                                  .fade(duration: 600.ms)
                                  .scale(delay: 200.ms),
                              const SizedBox(height: 8),
                              const Text(
                                'UniVault Admin Registration',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              )
                                  .animate()
                                  .fadeIn(delay: 300.ms)
                                  .moveX(begin: -10, end: 0),
                              const SizedBox(height: 4),
                              Text(
                                'Secure registration for approved administrators',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blueGrey.shade300,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 500.ms)
                                  .moveX(begin: -5, end: 0),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/university-of-ibadan-logo-transparent.png',
                          height: 80,
                          width: 100,
                          fit: BoxFit.fitHeight,
                        ).animate().fadeIn(delay: 700.ms).scale(delay: 700.ms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Visual progress stepper
                  RegistrationStepper(currentStep: _currentStep)
                      .animate()
                      .fadeIn(delay: 900.ms),
                  SizedBox(
                    width: 500,
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
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
      ),
    );
  }

  // Choose which widget to show based on the current registration step.
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

  // --------------------------
  // 1) SIGN-UP FORM
  // --------------------------
  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sign Up',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.2, end: 0),
          Divider(color: Colors.grey.withOpacity(.3)),
          const SizedBox(height: 25),
          ..._buildAnimatedFormField(
            label: 'Full Name',
            controller: _fullNameController,
            icon: Icons.person_outline_outlined,
            hintText: 'Enter your Full Name',
            validator: (value) {
              if (value.isNullOrEmpty) return 'Full Name is required.';
              if (!value.isValidName) return 'Enter a valid name.';
              return null;
            },
            delay: 100.ms,
          ),
          ..._buildAnimatedFormField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            hintText: 'Enter your Email',
            validator: (value) {
              if (value.isNullOrEmpty) return 'Email is required.';
              if (!value.isValidEmail) return 'Enter a valid email address.';
              return null;
            },
            delay: 200.ms,
          ),
          ..._buildAnimatedFormField(
            label: 'Phone number',
            controller: _phoneController,
            icon: Icons.phone_enabled_outlined,
            hintText: 'Enter your Phone Number',
            validator: (value) {
              if (value.isNullOrEmpty) return 'Phone number is required.';
              if (!value.isValidPhone) return 'Enter a valid phone number.';
              return null;
            },
            delay: 300.ms,
          ),
          ..._buildPasswordField(
            label: 'Password',
            controller: _passwordController,
            obscure: _obscurePassword,
            toggleObscure: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
            validator: (value) {
              if (value.isNullOrEmpty) return 'Password is required.';
              if (!value.isValidPassword) {
                return 'Password must be at least 8 characters and include uppercase, lowercase, digit, and special character.';
              }
              return null;
            },
            delay: 400.ms,
          ),
          // Password strength indicator
          Animate(
            effects: [FadeEffect(duration: 500.ms, delay: 450.ms)],
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              child: _buildPasswordStrengthIndicator(_passwordController.text),
            ),
          ),
          ..._buildPasswordField(
            label: 'Confirm Password',
            controller: _confirmPasswordController,
            obscure: _obscureConfirmPassword,
            toggleObscure: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
            validator: (value) {
              if (value!.isNullOrEmpty) return 'Please confirm your password.';
              if (!value.isPasswordMatch(_passwordController.text)) {
                return 'Passwords do not match.';
              }
              return null;
            },
            delay: 500.ms,
          ),
          const SizedBox(height: 10),
          // Verification method selection
          Animate(
            effects: [
              FadeEffect(duration: 500.ms, delay: 600.ms),
              const SlideEffect(begin: Offset(0.05, 0), end: Offset.zero)
            ],
            child: Row(
              children: [
                Radio<VerificationMethod>(
                  value: VerificationMethod.email,
                  groupValue: _selectedMethod,
                  activeColor: Colors.blue.shade800,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedMethod = val!);
                  },
                ),
                const Text('Verify by Email',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // Animated signup button
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
            child: Animate(
              effects: [FadeEffect(duration: 500.ms, delay: 700.ms)],
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
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _handleSignUp();
                    },
                    child: Center(
                      child: _isSignUpLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
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
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(begin: 1, end: 1.02, duration: 2000.ms),
            ),
          ),
          // Login link
          Animate(
            effects: [FadeEffect(duration: 500.ms, delay: 800.ms)],
            child: Center(
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          HapticFeedback.selectionClick();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                      text: ' Login',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Error message display
          if (_message.isNotEmpty)
            Animate(
              effects: [FadeEffect(duration: 300.ms)],
              child: Padding(
                padding: const EdgeInsets.only(top: 15.0),
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
            ),
        ],
      ),
    );
  }

  // Helper: Animated form field builder.
  List<Widget> _buildAnimatedFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    required String? Function(String?) validator,
    required Duration delay,
    TextInputAction? textInputAction = TextInputAction.next,
  }) {
    return [
      Animate(
        effects: [
          FadeEffect(duration: 500.ms, delay: delay),
          const SlideEffect(begin: Offset(0.05, 0), end: Offset.zero)
        ],
        child: Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 8),
      Animate(
        effects: [
          FadeEffect(duration: 500.ms, delay: delay + 50.ms),
          const SlideEffect(begin: Offset(0.05, 0), end: Offset.zero)
        ],
        child: TextFormField(
          controller: controller,
          textInputAction: textInputAction,
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
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            border: InputBorder.none,
            suffixIcon: Icon(icon, size: 18, color: Colors.black54),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            errorStyle: TextStyle(color: Colors.red.shade700),
          ),
          validator: validator,
        ),
      ),
      const SizedBox(height: 16),
    ];
  }

  // Helper: Password field with toggle.
  List<Widget> _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggleObscure,
    required String? Function(String?) validator,
    required Duration delay,
    TextInputAction? textInputAction = TextInputAction.next,
  }) {
    return [
      Animate(
        effects: [
          FadeEffect(duration: 500.ms, delay: delay),
          const SlideEffect(begin: Offset(0.05, 0), end: Offset.zero)
        ],
        child: Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 8),
      Animate(
        effects: [
          FadeEffect(duration: 500.ms, delay: delay + 50.ms),
          const SlideEffect(begin: Offset(0.05, 0), end: Offset.zero)
        ],
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          textInputAction: textInputAction,
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
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            border: InputBorder.none,
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            suffixIcon: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                toggleObscure();
              },
              child: Icon(
                obscure ? Icons.lock_outline : Icons.remove_red_eye,
                size: 18,
                color: Colors.black54,
              ),
            ),
            errorStyle: TextStyle(color: Colors.red.shade700),
          ),
          validator: validator,
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  // Password strength indicator.
  Widget _buildPasswordStrengthIndicator(String password) {
    int strength = _calculatePasswordStrength(password);
    final strengthText = _getStrengthText(strength);
    final strengthColor = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: strength / 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strengthText,
          style: TextStyle(
            color: strengthColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.isEmpty) return strength;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
        return 'Very weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      case 5:
        return 'Godlike';
      default:
        return '';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // --------------------------
  // 2) EMAIL VERIFICATION WAITING SCREEN
  // --------------------------
  Widget _buildEmailVerificationWait() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/lottie/email_sent.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Animate(
          effects: [
            FadeEffect(duration: 500.ms),
            const SlideEffect(begin: Offset(0, 0.05), end: Offset.zero)
          ],
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Text(
              'A verification link has been sent to your email. Please check your inbox and click the link to verify your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Animate(
          effects: [FadeEffect(duration: 500.ms, delay: 200.ms)],
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.blue.shade800,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _isEmailVerificationLoading
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              _checkEmailVerificationStatus();
                            },
                      child: Center(
                        child: _isEmailVerificationLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'I have verified, continue',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    border: Border.all(color: Colors.blue.shade800),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: _isResendEmailLoading
                          ? null
                          : () {
                              HapticFeedback.mediumImpact();
                              _resendEmailVerification();
                            },
                      child: Center(
                        child: _isResendEmailLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade800),
                              )
                            : Text(
                                'Resend Verification Email',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.blue.shade800),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_message.isNotEmpty)
          Animate(
            effects: [FadeEffect(duration: 300.ms)],
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.teal, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _message,
                      style: const TextStyle(color: Colors.teal, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // --------------------------
  // 3) OTP VERIFICATION SCREEN
  // --------------------------
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
              const SizedBox(height: 10),
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
                  'Enter the OTP sent to your email to complete your registration',
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
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Resend',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = _isResendOtpLoadin
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
                        _handleOtpVerification();
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

  // --------------------------
  // 4) SUCCESS SCREEN
  // --------------------------
  Widget _buildSuccessScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Animate(
          effects: [
            FadeEffect(duration: 500.ms),
            const ScaleEffect(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0))
          ],
          child: const Text(
            'Your account is verified!\nRegistration complete.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.green, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
          child: Animate(
            effects: [FadeEffect(duration: 500.ms, delay: 200.ms)],
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
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashboardPage()));
                  },
                  child: Center(
                    child: _isSignUpLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'Go to Dashboard',
                            textAlign: TextAlign.center,
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
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(begin: 1, end: 1.02, duration: 2000.ms),
          ),
        ),
        // Animate(
        //   effects: [FadeEffect(duration: 500.ms, delay: 200.ms)],
        //   child: ElevatedButton(
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.all(Colors.blue.shade800),
        //       padding: MaterialStateProperty.all(
        //           const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(15))),
        //     ),
        //     onPressed: () {
        //       Navigator.pushReplacement(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) => const DashboardPage()));
        //     },
        //     child: const Text('Go to Dashboard'),
        //   ),
        // ),
      ],
    );
  }

  // --------------------------
  // HANDLER METHODS
  // --------------------------
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _message = '';
      _isSignUpLoading = true;
    });

    try {
      if (_selectedMethod == VerificationMethod.email) {
        // Create user with email verification.
        final user = await _authService.createUserWithEmailVerification(
          fullName: fullName,
          email: email,
          password: password,
        );
        setState(() {
          _isRegistered = true;
          _currentStep = RegistrationStep.emailVerification;
          _message =
              'Sign-up successful. Check your email for a verification link.';
        });

        final otp = _authService.generateOtp();
        await _authService.storeOtp(user!.uid, otp);
        await _authService.sendOtpEmail(user.email!, otp);
      } else {
        // If you decide to implement phone verification later.
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
          // Optionally store OTP if needed:
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
        // Reset OTP verification status if needed
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
