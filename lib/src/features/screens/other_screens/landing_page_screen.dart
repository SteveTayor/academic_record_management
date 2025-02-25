import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth_screens/admin_signup.dart';
import '../auth_screens/login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavBar(context),
            _buildHeroSection(),
            _buildFeatureCards(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 10),
             Image.asset(
                        'assets/images/university-of-ibadan-logo-transparent.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.fitHeight,
                      )
              // _navButton('Features'),
              // _navButton('About'),
              // _navButton('Contact'),
            ],
          ),
          Text('UniVault',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              )),
          Row(
            children: [
              // _navButton('Features'),
              // _navButton('About'),
              // _navButton('Contact'),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Text('Login',
                    style: GoogleFonts.poppins(color: Colors.grey[700],)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AdminRegistrationPage()));
                },
                child: Text('Sign Up',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextButton(
        onPressed: () {},
        child: Text(text,
            style: GoogleFonts.poppins(
              color: Colors.grey[700],
              fontSize: 16,
            )),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text('Simple Academic Document Management',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              )),
          const SizedBox(height: 20),
          Text('Store, manage and retrieve academic records securely',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.grey[600],
              )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _featureCard(Icons.lock, 'Protected Storage',
              'Secure document storage with multi-factor'),
          _featureCard(Icons.search, 'Easy Retrieval',
              'Find documents quickly with smart search'),
          _featureCard(Icons.folder, 'Organization',
              'Keep documents organized and accessible'),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String description) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.blue[800]),
              const SizedBox(height: 20),
              Text(title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  )),
              const SizedBox(height: 10),
              Text(description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    height: 1.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      padding: const EdgeInsets.symmetric(vertical: 40),
      color: Colors.grey[100],
      child: Column(
        children: [
          Text('© 2024 UniVault',
              style: GoogleFonts.poppins(color: Colors.grey[600])),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Privacy Policy',
                    style: GoogleFonts.poppins(color: Colors.grey[600])),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {},
                child: Text('Terms of Use',
                    style: GoogleFonts.poppins(color: Colors.grey[600])),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {},
                child: Text('Contact',
                    style: GoogleFonts.poppins(color: Colors.grey[600])),
              ),
            ],
          )
        ],
      ),
    );
  }
}
