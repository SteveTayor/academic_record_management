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
      color: Colors.purple[100],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          _buildMenuItem('Overview', Icons.grid_view, selectedMenu == 'Overview'),
          _buildMenuItem('Documents', Icons.folder, selectedMenu == 'Documents'),
          _buildMenuItem('Users', Icons.person, selectedMenu == 'Users'),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.purple[700] : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.purple[700] : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onMenuSelected(title),
      selected: isSelected,
      selectedTileColor: Colors.purple[200],
    );
  }
}