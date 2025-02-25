import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const Sidebar({
    Key? key,
    required this.selectedMenu,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.15,
      color: Colors.blueGrey[50],
      child: Column(
        children: [
          // Top Section (Logo or App Title)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 10,
              children: [
                Image.asset(
                  'assets/images/university-of-ibadan-logo-transparent.png',
                  height: 40,
                  width: 80,
                  fit: BoxFit.contain,
                ),

                Text(
                  'UniVault',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                // Icon(Icons.add, color: Colors.white),
              ],
            ),
          ),
          // Menu Items
          _buildMenuItem(
              'Overview', Icons.grid_view, selectedMenu == 'Overview'),
          _buildMenuItem(
              'Documents', Icons.folder, selectedMenu == 'Documents'),
          // _buildMenuItem('Users', Icons.person, selectedMenu == 'Users'),

          // Spacer pushes user info to bottom if desired
          const Spacer(),

          // Bottom user info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                      'Admin User',
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
          leading: Icon(icon,
              color: isSelected ? Colors.lightBlue[50] : Colors.black),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            onMenuSelected(title);
            isSelected = !isSelected;
          },
          selected: isSelected,
          selectedColor: Colors.blue[800],
          selectedTileColor: Colors.blue[800],
        ),
      ),
    );
  }
}
