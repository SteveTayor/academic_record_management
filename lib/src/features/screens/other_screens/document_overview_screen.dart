// import 'package:flutter/material.dart';

// import '../../widgets/sidebar.dart';
// import '../dashborad/dashboard.dart';
// import 'document_view_screen.dart';

// class DocumentOverviewScreen extends StatefulWidget {
//   const DocumentOverviewScreen({Key? key}) : super(key: key);

//   @override
//   State<DocumentOverviewScreen> createState() => _DocumentOverviewScreenState();
// }

// class _DocumentOverviewScreenState extends State<DocumentOverviewScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Sidebar
//           Sidebar(
//             selectedMenu: 'Documents',
//             onMenuSelected: (menu) => _onSidebarMenuSelected(menu, context),
//           ),
//           // Main content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Documents > Overview',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildHeaderCards(context),
//                   const SizedBox(height: 24),
//                   _buildRecentDocumentsTable(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Two cards side-by-side: OCR Processing & Document Search
//   Widget _buildHeaderCards(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _buildInfoCard(
//             icon: Icons.text_snippet,
//             title: 'OCR Processing',
//             description:
//                 'Convert scanned documents into searchable text using OCR technology',
//             buttonText: 'Process Documents',
//             onPressed: () {
//               // Navigate to the OCR upload screen
//               Navigator.pushNamed(context, '/documents/ocr-upload');
//             },
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: _buildInfoCard(
//             icon: Icons.search,
//             title: 'Document Search',
//             description:
//                 'Search through processed documents using keywords and filters',
//             buttonText: 'Search Documents',
//             onPressed: () {
//               // Navigate to the Document Search screen
//               Navigator.pushNamed(context, '/documents/search');
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   /// A reusable widget for each card
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String title,
//     required String description,
//     required String buttonText,
//     required VoidCallback onPressed,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 36, color: Colors.blue),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(description, style: const TextStyle(color: Colors.grey)),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: onPressed,
//             child: Text(buttonText),
//           ),
//         ],
//       ),
//     );
//   }

//   /// A table for "Recent Documents"
//   Widget _buildRecentDocumentsTable() {
//     final documents = [
//       {
//         'fileName': 'Invoice.pdf',
//         'status': 'OCR Complete',
//         'category': 'Finance',
//         'date': '2024-01-20',
//       },
//       {
//         'fileName': 'Contract.pdf',
//         'status': 'Processing',
//         'category': 'Legal',
//         'date': '2024-01-19',
//       },
//       {
//         'fileName': 'Report.pdf',
//         'status': 'Queued',
//         'category': 'Operations',
//         'date': '2024-01-18',
//       },
//     ];

//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Recent Documents',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.white,
//               ),
//               child: DataTable(
//                 columns: const [
//                   DataColumn(label: Text('File Name')),
//                   DataColumn(label: Text('Status')),
//                   DataColumn(label: Text('Category')),
//                   DataColumn(label: Text('Date')),
//                   DataColumn(label: Text('Actions')),
//                 ],
//                 rows: documents.map((doc) {
//                   return DataRow(
//                     cells: [
//                       DataCell(Text(doc['fileName']!)),
//                       DataCell(Text(doc['status']!)),
//                       DataCell(Text(doc['category']!)),
//                       DataCell(Text(doc['date']!)),
//                       DataCell(
//                         Row(
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () {
//                                 // Handle edit
//                                 print('Edit ${doc['fileName']}');
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () {
//                                 // Handle delete
//                                 print('Delete ${doc['fileName']}');
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onSidebarMenuSelected(String menu, BuildContext context) {
//     if (menu == 'Overview') {
//       // TODO: Navigate to your Overview screen
//       Navigator.push(
//           context, MaterialPageRoute(builder: (_) => const DashboardPage()));
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Navigate to Overview')),
//       );
//     } else if (menu == 'Documents') {
//       // TODO: Navigate to Documents screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Navigate to Documents')),
//       );
//     } else if (menu == 'Users') {
//       // Already on "Users" (User Folder Screen)
//     } else {
//       // Add more logic if needed
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Navigate to $menu')),
//       );
//     }
//   }
// }
