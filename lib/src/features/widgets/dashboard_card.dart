import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Card(
        color: Colors.blueGrey[50], // Light purple background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.purple[800], size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: onPressed,
              //   // onPressed: () {
              //   //   // Placeholder for button action
              //   //   ScaffoldMessenger.of(context).showSnackBar(
              //   //     SnackBar(content: Text('$buttonText clicked')),
              //   //   );
              //   // },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue[800],
              //     foregroundColor: Colors.white,
              //     minimumSize: const Size(double.infinity, 36),
              //   ),
              //   child: Text(buttonText),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
