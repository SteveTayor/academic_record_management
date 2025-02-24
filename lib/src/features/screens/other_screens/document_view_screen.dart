import 'package:archival_system/src/features/screens/dashborad/dashboard.dart';
import 'package:archival_system/src/features/screens/other_screens/document_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your shared Sidebar widget
import '../../../core/model/document_model.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/sidebar.dart';
import 'ocr_screen.dart';

// Import your DocumentService and DocumentModel

class UserFolderScreen extends StatelessWidget {
  UserFolderScreen({Key? key}) : super(key: key);

  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1) Reusable Sidebar
          Sidebar(
            selectedMenu: 'Users',  // Example: highlight "Users"
            onMenuSelected: (menu) => _onSidebarMenuSelected(menu, context),
          ),

          // 2) Main Content
          Expanded(
            child: FutureBuilder<List<DocumentModel>>(
              // Fetch documents for a sample matric number
              future: _documentService.fetchDocuments(''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final documents = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Breadcrumb
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: const [
                          Text('Documents'),
                          Icon(Icons.chevron_right),
                          Text('User Folders'),
                        ],
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text(
                        'User Folders',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // List of User Folders
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            return _UserFolderItem(
                              name: doc.userName,
                              matricNumber: doc.matricNumber,
                              level: doc.level,
                              documents: [
                                _DocumentItem(
                                  name: 'Document ${index + 1}',
                                  type: doc.documentType,
                                  date: doc.timestamp.toString(),
                                  hasStructuredData: doc.structuredData != null,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
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

  // Handle sidebar navigation
  void _onSidebarMenuSelected(String menu, BuildContext context) {
    if (menu == 'Overview') {
      // TODO: Navigate to your Overview screen
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigate to Overview')),
      );
    } else if (menu == 'Documents') {
      // TODO: Navigate to Documents screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigate to Documents')),
      );
    } else if (menu == 'Users') {
      // Already on "Users" (User Folder Screen)
    } else {
      // Add more logic if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigate to $menu')),
      );
    }
  }
}

// --------------------------------------------------------------------
//  The expanded user folder item, containing one or more documents
// --------------------------------------------------------------------
class _UserFolderItem extends StatelessWidget {
  final String name;
  final String matricNumber;
  final String level;
  final List<_DocumentItem> documents;

  const _UserFolderItem({
    required this.name,
    required this.matricNumber,
    required this.level,
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.folder_outlined, color: Colors.blue),
      title: Text(name),
      subtitle: Text('$matricNumber - $level'),
      children: documents,
    );
  }
}

// --------------------------------------------------------------------
//  Individual document item inside a user folder
// --------------------------------------------------------------------
class _DocumentItem extends StatelessWidget {
  final String name;
  final String type;
  final String date;
  final bool hasStructuredData;

  const _DocumentItem({
    required this.name,
    required this.type,
    required this.date,
    required this.hasStructuredData,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        type == 'Transcript' ? Icons.description : Icons.mail_outline,
        color: Colors.grey,
      ),
      title: Text(name),
      subtitle: Text(type),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasStructuredData)
            const Icon(Icons.data_array, color: Colors.green),
          const SizedBox(width: 8),
          Text(date),
          const SizedBox(width: 16),
          const Icon(Icons.visibility_outlined),
          const SizedBox(width: 8),
          const Icon(Icons.download),
        ],
      ),
    );
  }
}
