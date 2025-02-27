import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../auth_screens/admin_signup.dart';
import '../auth_screens/login_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 80), // Space for the fixed navbar
                _buildTopSection(context),
                _buildWhyChooseUs(),
                _buildFeatureCards(),
                _buildStatistics(),
                _buildTestimonials(),
                _buildCTA(context),
                _buildFooter(),
              ],
            ),
          ),
          _buildNavBar(context),
        ],
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          color: _isScrolled ? Colors.white : Colors.transparent,
          boxShadow: _isScrolled
              ? [BoxShadow(color: Colors.black26, blurRadius: 5)]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/university-of-ibadan-logo-transparent.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.fitHeight,
                ),
                Text('UniVault',
                    style: GoogleFonts.poppins(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: _isScrolled ? Colors.blue[800] : Colors.black,
                    )),
              ],
            ),
            Row(
              children: [
                _navButton('Features'),
                _navButton('Why Us'),
                _navButton('Testimonials'),
                _navButton('Contact'),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.blue.shade800,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text('Login',
                      style: GoogleFonts.poppins(
                        color:
                            _isScrolled ? Colors.blue[800] : Colors.blue[800],
                        fontWeight: FontWeight.w500,
                      )),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AdminRegistrationPage()));
                  },
                  child: Text('Sign Up',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextButton(
        onPressed: () {},
        child: Text(text,
            style: GoogleFonts.poppins(
              color: _isScrolled ? Colors.blue[800] : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20), // Avoid overlapping navbar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800,
            Colors.blue.shade600,
            Colors.blue.shade400,
          ],
        ),
      ),
      child: Column(
        children: [
          _buildHeroSection(context),
        ],
      ),
    );
  }

  // Widget _buildTopSection(BuildContext context) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [
  //           Colors.blue.shade800,
  //           Colors.blue.shade600,
  //           Colors.blue.shade400,
  //         ],
  //       ),
  //     ),
  //     child: Column(
  //       children: [
  //         _buildNavBar(context),
  //         _buildHeroSection(context),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNavBar(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           children: [
  //             const SizedBox(width: 10),
  //             Image.asset(
  //               'assets/images/university-of-ibadan-logo-transparent.png',
  //               height: 50,
  //               width: 50,
  //               fit: BoxFit.fitHeight,
  //             ),
  //             Text('UniVault',
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 35,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.white,
  //                 )),
  //           ],
  //         ),
  //         Row(
  //           children: [
  //             _navButton('Features'),
  //             _navButton('Why Us'),
  //             _navButton('Testimonials'),
  //             _navButton('Contact'),
  //           ],
  //         ),
  //         Row(
  //           children: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => const LoginPage()));
  //               },
  //               child: Text('Login',
  //                   style: GoogleFonts.poppins(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w500,
  //                   )),
  //             ),
  //             const SizedBox(width: 10),
  //             ElevatedButton(
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.white,
  //                 foregroundColor: Colors.blue[800],
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               onPressed: () {
  //                 Navigator.of(context).push(MaterialPageRoute(
  //                     builder: (_) => const AdminRegistrationPage()));
  //               },
  //               child: Text('Sign Up',
  //                   style: GoogleFonts.poppins(
  //                     fontWeight: FontWeight.bold,
  //                   )),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _navButton(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15),
  //     child: TextButton(
  //       onPressed: () {},
  //       child: Text(text,
  //           style: GoogleFonts.poppins(
  //             color: Colors.white,
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //           )),
  //     ),
  //   );
  // }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Academic Document Management',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    )),
                const SizedBox(height: 20),
                Text(
                    'Store, manage and retrieve academic records securely with our state-of-the-art platform designed specifically for educational institutions.',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    )),
                const SizedBox(height: 40),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AdminRegistrationPage()));
                      },
                      child: Text('Get Started',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    const SizedBox(width: 20),
                    TextButton.icon(
                      icon: const Icon(Icons.play_circle_outline,
                          color: Colors.white, size: 24),
                      label: Text('Watch Demo',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Lottie.asset(
              'assets/lottie/document-illustration.json',
              // width: 200,
              // height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.insert_drive_file,
                      size: 120,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
            // Image.asset(
            //   'assets/images/document-illustration.png',
            //   // If this asset doesn't exist, you'll need to add it or replace with another available image
            //   fit: BoxFit.contain,
            //   errorBuilder: (context, error, stackTrace) {
            //     return Container(
            //       height: 350,
            //       decoration: BoxDecoration(
            //         color: Colors.white.withOpacity(0.2),
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //       child: Center(
            //         child: Icon(
            //           Icons.insert_drive_file,
            //           size: 120,
            //           color: Colors.white.withOpacity(0.7),
            //         ),
            //       ),
            //     );
            //   },
            // ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text('Why Choose UniVault',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              )),
          const SizedBox(height: 15),
          Text(
              'We provide a comprehensive solution for educational institutions to manage academic records',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              )),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _whyChooseUsItem(Icons.security, 'Enhanced Security',
                  'Multi-factor authentication and end-to-end encryption to protect sensitive academic data.'),
              _whyChooseUsItem(Icons.speed, 'Time Efficiency',
                  'Reduce document retrieval time by up to 80% with our intelligent search system.'),
              _whyChooseUsItem(
                  Icons.integration_instructions,
                  'Easy Integration',
                  'Seamlessly integrates with existing school management systems and databases.'),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _whyChooseUsItem(Icons.support_agent, '24/7 Support',
                  'Our dedicated support team is available round the clock to assist with any issues.'),
              _whyChooseUsItem(Icons.cloud_done, 'Cloud Backup',
                  'Automatic cloud backups ensure your data is never lost and always accessible.'),
              _whyChooseUsItem(Icons.update, 'Regular Updates',
                  'Continuous updates and improvements based on user feedback and technological advancements.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whyChooseUsItem(IconData icon, String title, String description) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue[50],
            child: Icon(icon, size: 40, color: Colors.blue[800]),
          ),
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
    );
  }

  Widget _buildFeatureCards() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text('Key Features',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              )),
          const SizedBox(height: 15),
          Text('Discover what makes our platform the preferred choice',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              )),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _featureCard(Icons.lock, 'Protected Storage',
                  'Secure document storage with multi-factor authentication and encryption.'),
              _featureCard(Icons.search, 'Easy Retrieval',
                  'Find documents quickly with smart search functionality and filters.'),
              _featureCard(Icons.folder, 'Organization',
                  'Keep documents organized with customizable categorization and tagging.'),
            ],
          ),
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
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Icon(icon, size: 50, color: Colors.blue[800]),
              const SizedBox(height: 20),
              Text(title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  )),
              const SizedBox(height: 15),
              Text(description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text('UniVault in Numbers',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              )),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statisticItem('50+', 'Institutions'),
              _statisticItem('500K+', 'Documents Stored'),
              _statisticItem('99.9%', 'Uptime'),
              _statisticItem('85%', 'Time Saved'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statisticItem(String number, String label) {
    return Column(
      children: [
        Text(number,
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            )),
        Text(label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
            )),
      ],
    );
  }

  Widget _buildTestimonials() {
    return Container(
      color: Colors.blue[50],
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text('What Our Users Say',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              )),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _testimonialCard(
                  'Dr. Adebayo Johnson',
                  'Registrar, University of Lagos',
                  'UniVault has revolutionized how we manage student records. The search functionality alone has saved my team countless hours.'),
              _testimonialCard(
                  'Prof. Sarah Okonkwo',
                  'Dean of Students, Covenant University',
                  'The security features give us peace of mind that our sensitive academic records are protected. The interface is also incredibly user-friendly.'),
              _testimonialCard(
                  'Mr. Emmanuel Nwachukwu',
                  'IT Director, University of Nigeria',
                  'Implementation was smooth and the support team was exceptional throughout the process. Would highly recommend to any educational institution.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testimonialCard(String name, String position, String testimonial) {
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
              Icon(Icons.format_quote, size: 40, color: Colors.blue[300]),
              const SizedBox(height: 20),
              Text(testimonial,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    height: 1.5,
                  )),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              Text(name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  )),
              const SizedBox(height: 5),
              Text(position,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text('Ready to Transform Your Document Management?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              )),
          const SizedBox(height: 20),
          Text(
              'Join educational institutions across the country in modernizing their academic record systems',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.grey[600],
              )),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AdminRegistrationPage()));
            },
            child: Text('Get Started Today',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Text('Contact Us for a Demo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      color: Colors.blue[900],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/university-of-ibadan-logo-transparent.png',
                        height: 40,
                        width: 40,
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.school,
                              size: 40, color: Colors.white);
                        },
                      ),
                      const SizedBox(width: 10),
                      Text('UniVault',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: 250,
                    child: Text(
                        'Secure, efficient academic document management for educational institutions.',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        )),
                  ),
                ],
              ),
              // Quick Links
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Links',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 15),
                  _footerLink('Features'),
                  _footerLink('Why Choose Us'),
                  _footerLink('Testimonials'),
                  _footerLink('Pricing'),
                ],
              ),
              // Support
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Support',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 15),
                  _footerLink('Help Center'),
                  _footerLink('Documentation'),
                  _footerLink('Contact Us'),
                  _footerLink('FAQ'),
                ],
              ),
              // Contact
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.email,
                          color: Colors.white.withOpacity(0.8), size: 18),
                      const SizedBox(width: 10),
                      Text('info@univault.edu',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                          )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone,
                          color: Colors.white.withOpacity(0.8), size: 18),
                      const SizedBox(width: 10),
                      Text('+234 123 456 7890',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                          )),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 60),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('© 2024 UniVault. All rights reserved.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                  )),
              Row(
                children: [
                  _footerBottomLink('Privacy Policy'),
                  const SizedBox(width: 20),
                  _footerBottomLink('Terms of Use'),
                  const SizedBox(width: 20),
                  _footerBottomLink('Cookie Policy'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(text,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
            )),
      ),
    );
  }

  Widget _footerBottomLink(String text) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          )),
    );
  }
}
