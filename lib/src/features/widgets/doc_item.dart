// Individual Document Item
import 'package:flutter/material.dart';

import '../../core/model/document_model.dart';

// class DocumentItem extends StatelessWidget {
//   final String name;
//   final String type;
//   final String date;
//   final bool hasStructuredData;

//   const DocumentItem({
//     super.key,
//     required this.name,
//     required this.type,
//     required this.date,
//     required this.hasStructuredData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(
//         type == 'Transcript' ? Icons.description : Icons.mail_outline,
//         color: Colors.grey,
//       ),
//       title: Text(name),
//       subtitle: Text(type),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (hasStructuredData)
//             const Icon(Icons.data_array, color: Colors.green),
//           const SizedBox(width: 8),
//           Text(date),
//           const SizedBox(width: 16),
//           const Icon(Icons.visibility_outlined),
//           const SizedBox(width: 8),
//           const Icon(Icons.download),
//         ],
//       ),
//     );
//   }
// }
class DocumentItem extends StatelessWidget {
  final DocumentModel document;

  const DocumentItem({required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          document.documentType == 'Transcript'
              ? Icons.description
              : Icons.mail_outline,
          size: 32,
        ),
        title: Text(document.documentType),
        subtitle: Text(document.level),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (document.structuredData != null)
              const Icon(Icons.data_array, color: Colors.green),
            const SizedBox(width: 16),
            const Icon(Icons.visibility_outlined),
          ],
        ),
        onTap: () => _showDocumentDetails(context),
      ),
    );
  }

  void _showDocumentDetails(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => DocumentDetailScreen(document: document),
    //   ),
    // );
  }
}
