enum VerificationMethod {
  email,
  phone,
}

enum RegistrationStep {
  signUp,
  emailVerification,
  otpVerification,
  complete,
}

enum LoginStep {
  enterCredentials,
  verifyOtp,
  complete,
}
