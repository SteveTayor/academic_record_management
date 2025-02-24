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
      width: 200,
      color: Colors.blue[800],
      child: Column(
        children: [
          // Top Section (Logo or App Title)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UniVault',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.add, color: Colors.black),
              ],
            ),
          ),
          // Menu Items
          _buildMenuItem('Overview', Icons.grid_view, selectedMenu == 'Overview'),
          _buildMenuItem('Documents', Icons.folder, selectedMenu == 'Documents'),
          _buildMenuItem('Users', Icons.person, selectedMenu == 'Users'),

          // Spacer pushes user info to bottom if desired
          const Spacer(),

          // Bottom user info
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 24),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
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
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue[700] : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue[700] : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onMenuSelected(title),
      selected: isSelected,
      selectedTileColor: Colors.blue[200],
    );
  }
}
