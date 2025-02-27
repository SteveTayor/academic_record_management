import 'package:flutter/material.dart';
import '../../../../core/model/document_model.dart';
import '../../../../core/service/document_service.dart';
import '../../../widgets/sidebar.dart';
import '../../../widgets/user_folder_item.dart';
import '../../dashborad/dashboard.dart';
import 'document_screen.dart';
import 'user_folder.dart';

// class MainFolderScreen extends StatelessWidget {
//   final String searchQuery;

//   MainFolderScreen({Key? key, required this.searchQuery}) : super(key: key);

//   final DocumentService _documentService = DocumentService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Sidebar remains visible
//           Sidebar(
//             selectedMenu: 'Documents',
//             onMenuSelected: (menu) => _onSidebarMenuSelected(menu, context),
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Breadcrumb
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () => Navigator.pop(context),
//                         child: const Text('Documents',
//                             style: TextStyle(color: Colors.blue)),
//                       ),
//                       const Icon(Icons.chevron_right),
//                       const Text('Main Folders'),
//                     ],
//                   ),
//                 ),
//                 // Title
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Text(
//                     'Main Folders',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 // Document List
//                 Expanded(
//                   child: FutureBuilder<List<DocumentModel>>(
//                     future: _documentService., // Fetch all documents
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }

//                       final documents = snapshot.data ?? [];

//                       // Filter documents based on search query
//                       final filteredDocs = searchQuery.isEmpty
//                           ? documents
//                           : documents.where((doc) {
//                               return doc.userName
//                                       .toLowerCase()
//                                       .contains(searchQuery.toLowerCase()) ||
//                                   doc.matricNumber
//                                       .toLowerCase()
//                                       .contains(searchQuery.toLowerCase()) ||
//                                   doc.level
//                                       .toLowerCase()
//                                       .contains(searchQuery.toLowerCase()) ||
//                                   doc.documentType
//                                       .toLowerCase()
//                                       .contains(searchQuery.toLowerCase());
//                             }).toList();

//                       // Group documents by user
//                       final Map<String, Map<String, List<DocumentModel>>>
//                           userFolders = {};
//                       for (var doc in filteredDocs) {
//                         final userKey = '${doc.userName} (${doc.matricNumber})';
//                         userFolders.putIfAbsent(userKey, () => {});
//                         userFolders[userKey]!.putIfAbsent(doc.level, () => []);
//                         userFolders[userKey]![doc.level]!.add(doc);
//                       }

//                       if (userFolders.isEmpty) {
//                         return const Center(
//                             child: Text('No matching documents found.'));
//                       }

//                       return ListView.builder(
//                         padding: const EdgeInsets.all(16.0),
//                         itemCount: userFolders.keys.length,
//                         itemBuilder: (context, index) {
//                           final userKey = userFolders.keys.elementAt(index);
//                           final levels = userFolders[userKey]!.keys.toList();
//                           return UserFolderItem(
//                             userKey: userKey,
//                             levels: levels,
//                             levelDocs: userFolders[userKey]!,
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// }
// void _onSidebarMenuSelected(String menu, BuildContext context) {
//   if (menu == 'Documents') {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
//     );
//   } else if (menu == 'Overview') {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const DashboardPage()),
//     );
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Navigate to $menu')),
//     );
//   }
// }
class MainFolderScreen extends StatelessWidget {
  final String searchQuery;

  MainFolderScreen({super.key, required this.searchQuery});

  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedMenu: 'Documents',
            onMenuSelected: (menu) => _onSidebarMenuSelected(menu, context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBreadcrumb(context),
                _buildTitle(),
                _buildUserList(),
              ],
            ),
          ),
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
            child:
                const Text('Documents', style: TextStyle(color: Colors.blue)),
          ),
          const Icon(Icons.chevron_right),
          const Text('Main Folders'),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Main Folders',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, String>>>(
        future: _documentService.fetchAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          final filteredUsers = _filterUsers(users);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) => UserFolderItem(
              user: filteredUsers[index],
              onTap: () => _navigateToUserFolder(context, filteredUsers[index]),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, String>> _filterUsers(List<Map<String, String>> users) {
    if (searchQuery.isEmpty) return users;

    return users.where((user) {
      final name = user['name']?.toLowerCase() ?? '';
      final matric = user['matricNumber']?.toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase()) ||
          matric.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToUserFolder(BuildContext context, Map<String, String> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFolderScreen(
          userName: user['name']!,
          matricNumber: user['matricNumber']!,
        ),
      ),
    );
  }

  void _onSidebarMenuSelected(String menu, BuildContext context) {
    if (menu == 'Documents') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
      );
    } else if (menu == 'Overview') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigate to $menu')),
      );
    }
  }
}
