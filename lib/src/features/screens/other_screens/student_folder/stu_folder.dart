// Modified UserFolderScreen
import 'package:flutter/material.dart';
import '../../../../core/service/document_service.dart';
import 'student_level_doc_screen.dart'; // We'll create this next

class UserFolderScreen extends StatelessWidget {
  final String userName;
  final String matricNumber;

  UserFolderScreen({
    required this.userName,
    required this.matricNumber,
    super.key,
  });

  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName Folders'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumb(context),
          _buildTitle(),
          _buildLevelFoldersList(),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Main Folders',
                style: TextStyle(color: Colors.blue)),
          ),
          const Icon(Icons.chevron_right),
          Text('$userName ($matricNumber)'),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Academic Levels',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLevelFoldersList() {
    return Expanded(
      child: FutureBuilder<List<String>>(
        future: _documentService.fetchLevelsForUser(matricNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No levels found for this student'));
          }

          final levels = snapshot.data!;
          // Sort levels by numeric value
          levels.sort((a, b) {
            final aNum = int.tryParse(a.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
            final bNum = int.tryParse(b.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
            return aNum.compareTo(bNum);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: levels.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading:
                      const Icon(Icons.folder, color: Colors.amber, size: 40),
                  title: Text(levels[index],
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Click to view documents'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LevelDocumentsScreen(
                          userName: userName,
                          matricNumber: matricNumber,
                          level: levels[index],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
