import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const Sidebar({
    Key? key,
    required this.selectedMenu,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final width =
        isCollapsed ? 120.0 : MediaQuery.of(context).size.width * 0.15;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      color: Colors.blueGrey[50],
      child: Column(
        children: [
          // Top Section with Logo and Toggle Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed)
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/university-of-ibadan-logo-transparent.png',
                        height: 40,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'UniVault',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  )
                else
                  Image.asset(
                    'assets/images/university-of-ibadan-logo-transparent.png',
                    height: 30,
                    width: 30,
                    fit: BoxFit.contain,
                  ),
                if (!isCollapsed) // Show toggle only when expanded
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blue[800],
                    ),
                    onPressed: () {
                      setState(() {
                        isCollapsed = !isCollapsed;
                      });
                    },
                  )
                else // Show toggle centered when collapsed
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue[800],
                    ),
                    onPressed: () {
                      setState(() {
                        isCollapsed = !isCollapsed;
                      });
                    },
                  ),
              ],
            ),
          ),

          // Menu Items
          _buildMenuItem(
              'Overview', Icons.grid_view, widget.selectedMenu == 'Overview'),
          _buildMenuItem(
              'Documents', Icons.folder, widget.selectedMenu == 'Documents'),

          // Spacer to push user info to bottom
          const Spacer(),

          // Admin Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseAuth.instance.currentUser != null
                  ? FirebaseFirestore.instance
                      .collection('admins')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return isCollapsed
                      ? const CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person, size: 24),
                        )
                      : Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Loading...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                const Text(
                                  'System Administrator',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        );
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final adminName = data?['fullName'] ?? 'Admin User';

                return isCollapsed
                    ? const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person, size: 24),
                      )
                    : Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adminName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              const Text(
                                'System Administrator',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[800] : null,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.lightBlue[50] : Colors.black,
          ),
          title: isCollapsed
              ? null
              : Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
          onTap: () {
            widget.onMenuSelected(title);
          },
          selected: isSelected,
          selectedColor: Colors.blue[800],
          selectedTileColor: Colors.blue[800],
        ),
      ),
    );
  }
}
