import 'package:flutter/material.dart';
import '../screens/auth_screens/enum.dart';

class RegistrationStepper extends StatelessWidget {
  final RegistrationStep currentStep;

  const RegistrationStepper({Key? key, required this.currentStep})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a horizontal stepper that shows each step and highlights the current one.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: RegistrationStep.values
          .map((step) => _buildStepIndicator(step))
          .toList(),
    );
  }

  Widget _buildStepIndicator(RegistrationStep step) {
    bool isActive = step == currentStep;
    bool isCompleted = step.index < currentStep.index;

    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isCompleted
              ? Colors.green
              : (isActive ? Colors.blue : Colors.grey),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text(
                  '${step.index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          _getStepLabel(step),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _getStepLabel(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.signUp:
        return 'Sign Up';
      case RegistrationStep.emailVerification:
        return 'Email Verify';
      case RegistrationStep.otpVerification:
        return 'OTP Verify';
      case RegistrationStep.complete:
        return 'Complete';
      default:
        return '';
    }
  }
}
