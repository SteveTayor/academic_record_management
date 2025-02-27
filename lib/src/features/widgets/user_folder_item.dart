import 'package:flutter/material.dart';

import '../../core/model/document_model.dart';
import 'doc_item.dart';

// class UserFolderItem extends StatelessWidget {
//   final String userKey;
//   final List<String> levels;
//   final Map<String, List<DocumentModel>> levelDocs;

//   const UserFolderItem({
//     required this.userKey,
//     required this.levels,
//     required this.levelDocs,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       leading: const Icon(Icons.folder_outlined, color: Colors.blue),
//       title: Text(userKey),
//       children: levels.map((level) {
//         return ExpansionTile(
//           title: Text('Level $level'),
//           children: levelDocs[level]!.map((doc) {
//             return DocumentItem(
//               name: doc.documentType,
//               type: doc.documentType,
//               date: doc.timestamp.toString(),
//               hasStructuredData: doc.structuredData != null,
//             );
//           }).toList(),
//         );
//       }).toList(),
//     );
//   }
// }
class UserFolderItem extends StatelessWidget {
  final Map<String, String> user;
  final VoidCallback onTap;

  const UserFolderItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.person_outline, size: 32),
        title: Text(user['name'] ?? 'Unknown User'),
        subtitle: Text('Matric: ${user['matricNumber']}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
