// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../core/model/document_model.dart';

// class DocumentDetailScreen extends StatelessWidget {
//   final DocumentModel document;

//   const DocumentDetailScreen({
//     required this.document,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(document.documentType),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               // Implement share functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text('Share functionality coming soon')),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () {
//               // Implement download functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Download started')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildBreadcrumb(context),
//             _buildDocumentHeader(),
//             _buildDocumentMetadata(),
//             _buildDocumentContent(),
//             _buildActionButtons(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBreadcrumb(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: const Text('Back to Documents',
//                 style: TextStyle(color: Colors.blue)),
//           ),
//           const Icon(Icons.chevron_right),
//           Expanded(
//             child: Text(
//               document.documentType,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       color: Colors.grey[100],
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           _getDocumentIconLarge(document.documentType),
//           const SizedBox(height: 16),
//           Text(
//             document.documentType,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Document ID: ${document.id}',
//             style: TextStyle(
//               color: Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentMetadata() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Document Information',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               _buildInfoRow('Student ID', document.matricNumber),
//               _buildInfoRow('Level', document.level),
//               _buildInfoRow('Date Processed', _formatDate(document.timestamp)),
//               _buildInfoRow(
//                   'File Format', _getFileFormat(document.documentType)),
//               _buildInfoRow('Name', document.userName),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           if (label == 'Document ID')
//             IconButton(
//               icon: const Icon(Icons.copy, size: 20),
//               onPressed: () {
//                 Clipboard.setData(ClipboardData(text: value));
//                 // Show a snackbar or toast
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDocumentContent() {
//     // This would be replaced with actual document content rendering
//     // For now, just showing a placeholder
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Card(
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Document Preview',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 height: 300,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.description,
//                         size: 64,
//                         color: Colors.grey[500],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         document.structuredData as String? ??
//                             'Preview not available',
//                         style: TextStyle(color: Colors.grey[700]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           ElevatedButton.icon(
//             icon: const Icon(Icons.download),
//             label: const Text('Download'),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Downloading document...')),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//           ),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.print),
//             label: const Text('Print'),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text('Preparing document for printing...')),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//           ),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.share),
//             label: const Text('Share'),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Share options coming soon')),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _getDocumentIconLarge(String documentType) {
//     IconData iconData;
//     Color iconColor;

//     switch (documentType.toLowerCase()) {
//       case 'transcript':
//         iconData = Icons.school;
//         iconColor = Colors.blue;
//         break;
//       case 'letter':
//         iconData = Icons.mail;
//         iconColor = Colors.green;
//         break;
//       default:
//         iconData = Icons.description;
//         iconColor = Colors.grey;
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: iconColor.withOpacity(0.1),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(iconData, color: iconColor, size: 64),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   String _getFileFormat(String documentType) {
//     switch (documentType.toLowerCase()) {
//       case 'transcript':
//         return 'PDF';
//       case 'letter':
//         return 'PDF';
//       default:
//         return 'PDF';
//     }
//   }
// }
