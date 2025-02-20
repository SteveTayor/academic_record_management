
extension StringValidationExtensions on String? {
  /// Returns true if the string is null or empty (after trimming).
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  /// Validates a name.
  /// - Must not be empty.
  /// - Must contain only letters, spaces, hyphens, or apostrophes.
  /// - Must be at least 2 characters.
  bool get isValidName {
    if (isNullOrEmpty) return false;
    final nameRegex = RegExp(r"^[A-Za-z][A-Za-z '-]{1,}$");
    return nameRegex.hasMatch(this!.trim());
  }

  /// Validates an email using a relatively complex regex.
  bool get isValidEmail {
    if (isNullOrEmpty) return false;
    // This regex ensures that the email does not start or end with a dot
    // and includes a valid domain.
    final emailRegex = RegExp(
      r"^(?!\.)[A-Za-z0-9!#$%&'*+\-/=?^_`{|}~\.]+(?<!\.)@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*(\.[A-Za-z]{2,})$"
    );
    return emailRegex.hasMatch(this!.trim());
  }

  /// Validates a phone number.
  /// - Optionally starts with a '+'.
  /// - Contains 10 to 15 digits.
  bool get isValidPhone {
    if (isNullOrEmpty) return false;
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(this!.trim());
  }

  /// Validates a password.
  /// - At least 8 characters.
  /// - Contains at least one uppercase letter.
  /// - Contains at least one lowercase letter.
  /// - Contains at least one digit.
  /// - Contains at least one special character.
  bool get isValidPassword {
    if (isNullOrEmpty) return false;
    final passwordRegex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(this!.trim());
  }

  /// Checks if this string matches the [confirm] string.
  bool isPasswordMatch(String? confirm) {
    if (this == null || confirm == null) return false;
    return this!.trim() == confirm.trim();
  }
}
