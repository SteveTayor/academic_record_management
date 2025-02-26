import 'package:archival_system/src/features/screens/other_screens/document_overview_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/model/document_model.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/sidebar.dart';
import '../other_screens/dcuments/document_screen.dart';
import '../other_screens/document_view_screen.dart';
import '../other_screens/ocr_screen.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({Key? key}) : super(key: key);

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   static const Color lightblue = Color.fromARGB(255, 132, 132, 240);
//   static const Color white = Colors.white;
//   static Color blue = Colors.blue.shade700;
//   static const Color black = Colors.black;

//   final DocumentService _documentService = DocumentService();
//   static const int _mockTotalDocuments = 45;
//   static const int _mockRecentRetrievals = 5;
//   static List<DocumentModel> _mockRecentDocuments = [
//     DocumentModel(
//       id: '1',
//       userName: 'Samuel Adeokun',
//       matricNumber: '220118',
//       level: '300 Level',
//       documentType: 'Transcript',
//       text: 'Sample text',
//       timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//       fileUrl: '',
//     ),
//     DocumentModel(
//       id: '2',
//       userName: 'Janet Slyia',
//       matricNumber: '202989',
//       level: '200 Level',
//       documentType: 'Letter',
//       text: 'Sample text',
//       timestamp: DateTime.now().subtract(const Duration(days: 1)),
//       fileUrl: '',
//     ),
//     DocumentModel(
//       id: '3',
//       userName: 'Michael Jonathan',
//       matricNumber: '203323',
//       level: '400 Level',
//       documentType: 'Report',
//       text: 'Sample text',
//       timestamp: DateTime.now().subtract(const Duration(days: 3)),
//       fileUrl: '',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Optional: keep an app bar or remove it if you want a full-screen approach
//       // appBar: AppBar(
//       //   title: const Text('Dashboard Overview'),
//       //   centerTitle: true,
//       //   backgroundColor: white,
//       //   foregroundColor: black,
//       //   elevation: 0,
//       // ),
//       backgroundColor: white,
//       body: Row(
//         children: [
//           // 1) The Sidebar
//           Sidebar(
//             selectedMenu: 'Overview', // This page is "Overview"
//             onMenuSelected: _onSidebarMenuSelected,
//           ),
//           // 2) Main content area
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 20),
//                   const Text(
//                     'Dashboard Overview',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: black,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDashboardMetrics(context),
//                   const SizedBox(height: 24),
//                   // Center(child: _buildQuickActions()),
//                   const SizedBox(height: 24),
//                   _buildRecentDocumentAccess(context),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDashboardMetrics(BuildContext context) {
//     return Wrap(
//       spacing: 16,
//       runSpacing: 16,
//       children: [
//         DashboardCard(
//             icon: Icons.folder,
//             title: 'Total Documents',
//             subtitle: '$_mockTotalDocuments files stored',
//             buttonText: 'View All',
//             onPressed: () {
//               // _showSnack('View All Documents clicked'),
//             }),
//         DashboardCard(
//             icon: Icons.refresh,
//             title: 'Recent Retrievals',
//             subtitle: '$_mockRecentRetrievals documents this week',
//             buttonText: 'See Details',
//             onPressed: () {
//               // _showSnack('See Recent Retrievals clicked'),
//             }),
//       ],
//     );
//   }

//   Widget _buildRecentDocumentAccess(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Recent Document Access',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: black,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildRecentDocumentsTable(),
//       ],
//     );
//   }

//   Widget _buildRecentDocumentsTable() {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.grey[100],
//       ),
//       child: DataTable(
//         columnSpacing: 24,
//         columns: const [
//           DataColumn(
//               label: Text('Document',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           DataColumn(
//               label:
//                   Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
//           DataColumn(
//               label: Text('Action',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//           DataColumn(
//               label: Text('Timestamp',
//                   style: TextStyle(fontWeight: FontWeight.bold))),
//         ],
//         rows: _mockRecentDocuments.map((doc) {
//           return DataRow(cells: [
//             DataCell(Text('${doc.documentType}.pdf')),
//             DataCell(Text(doc.userName)),
//             const DataCell(Text('View', style: TextStyle(color: Colors.blue))),
//             DataCell(Text(_formatTimestamp(doc.timestamp))),
//           ]);
//         }).toList(),
//       ),
//     );
//   }

//   /// Handle sidebar navigation
//   void _onSidebarMenuSelected(String menu) {
//     if (menu == 'Overview') {
//       // Already on the dashboard, do nothing or pop
//     } else if (menu == 'Documents') {
//       // TODO: Navigate to a Documents page or screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Navigate to Documents screen')),
//       );
//     } else if (menu == 'Users') {
//       // TODO: Navigate to a Users page or screen
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(builder: (_) => UserFolderScreen()),
//       // );
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   const SnackBar(content: Text('Navigate to Users screen')),
//       // );
//     }
//   }

//   // /// Dashboard metrics (uses Firestore to fetch data)
//   // Widget _buildDashboardMetrics(BuildContext context) {
//   //   return FutureBuilder<Map<String, dynamic>>(
//   //     future: _fetchDashboardMetrics(),
//   //     builder: (context, snapshot) {
//   //       if (snapshot.connectionState == ConnectionState.waiting) {
//   //         return const Center(child: CircularProgressIndicator());
//   //       }
//   //       if (snapshot.hasError) {
//   //         return const Center(child: Text('Error loading metrics'));
//   //       }
//   //       final data = snapshot.data ?? {};
//   //       final totalDocuments = data['totalDocuments'] ?? 0;
//   //       final recentRetrievals = data['recentRetrievals'] ?? 0;

//   //       return Wrap(
//   //         spacing: 16,
//   //         runSpacing: 16,
//   //         children: [
//   //           DashboardCard(
//   //             icon: Icons.folder,
//   //             title: 'Total Documents',
//   //             subtitle: '$totalDocuments files stored',
//   //             buttonText: 'View All',
//   //             onPressed: () {
//   //               // Placeholder for navigation to documents list
//   //               ScaffoldMessenger.of(context).showSnackBar(
//   //                 const SnackBar(content: Text('View All Documents clicked')),
//   //               );
//   //             },
//   //           ),
//   //           DashboardCard(
//   //             icon: Icons.refresh,
//   //             title: 'Recent Retrievals',
//   //             subtitle: '$recentRetrievals documents this week',
//   //             buttonText: 'See Details',
//   //             onPressed: () {
//   //               // Placeholder for navigation to recent retrievals
//   //               ScaffoldMessenger.of(context).showSnackBar(
//   //                 const SnackBar(
//   //                     content: Text('See Recent Retrievals clicked')),
//   //               );
//   //             },
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }

//   // /// Quick actions section
//   // Widget _buildQuickActions() {
//   //   return ElevatedButton(
//   //     onPressed: () {
//   //       // Example: navigate to OCR upload screen
//   //       Navigator.push(
//   //         context,
//   //         MaterialPageRoute(builder: (_) => const OcrUploadScreen()),
//   //       );
//   //     },
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: blue,
//   //       foregroundColor: white,
//   //       padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//   //       textStyle: const TextStyle(fontSize: 16),
//   //     ),
//   //     child: const Text('Upload New Document'),
//   //   );
//   // }

//   // /// Recent documents table
//   // Widget _buildRecentDocumentAccess(BuildContext context) {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       const Text(
//   //         'Recent Document Access',
//   //         style: TextStyle(
//   //           fontSize: 18,
//   //           fontWeight: FontWeight.bold,
//   //           color: black,
//   //         ),
//   //       ),
//   //       const SizedBox(height: 8),
//   //       FutureBuilder<List<DocumentModel>>(
//   //         future: _fetchRecentDocuments(),
//   //         builder: (context, snapshot) {
//   //           if (snapshot.connectionState == ConnectionState.waiting) {
//   //             return const Center(child: CircularProgressIndicator());
//   //           }
//   //           if (snapshot.hasError) {
//   //             return const Center(
//   //                 child: Text('Error loading recent documents'));
//   //           }
//   //           final documents = snapshot.data ?? [];
//   //           if (documents.isEmpty) {
//   //             return const Center(child: Text('No recent documents found'));
//   //           }
//   //           return SingleChildScrollView(
//   //             scrollDirection: Axis.horizontal,
//   //             child: DataTable(
//   //               columnSpacing: 24,
//   //               columns: const [
//   //                 DataColumn(
//   //                   label: Text(
//   //                     'Document',
//   //                     style: TextStyle(fontWeight: FontWeight.bold),
//   //                   ),
//   //                 ),
//   //                 DataColumn(
//   //                   label: Text(
//   //                     'User',
//   //                     style: TextStyle(fontWeight: FontWeight.bold),
//   //                   ),
//   //                 ),
//   //                 DataColumn(
//   //                   label: Text(
//   //                     'Action',
//   //                     style: TextStyle(fontWeight: FontWeight.bold),
//   //                   ),
//   //                 ),
//   //                 DataColumn(
//   //                   label: Text(
//   //                     'Timestamp',
//   //                     style: TextStyle(fontWeight: FontWeight.bold),
//   //                   ),
//   //                 ),
//   //                 DataColumn(label: Text('')), // For three-dot menu
//   //               ],
//   //               rows: documents.map((doc) {
//   //                 return DataRow(cells: [
//   //                   DataCell(Text(doc.documentType.isNotEmpty
//   //                       ? '${doc.documentType}.pdf'
//   //                       : 'Unknown.pdf')),
//   //                   DataCell(Text(doc.userName)),
//   //                   const DataCell(Text('View')),
//   //                   DataCell(Text(_formatTimestamp(doc.timestamp))),
//   //                   DataCell(
//   //                     IconButton(
//   //                       icon: const Icon(Icons.more_vert),
//   //                       onPressed: () {
//   //                         // Placeholder for menu action
//   //                         ScaffoldMessenger.of(context).showSnackBar(
//   //                           SnackBar(
//   //                             content: Text(
//   //                               'More options for ${doc.documentType} clicked',
//   //                             ),
//   //                           ),
//   //                         );
//   //                       },
//   //                     ),
//   //                   ),
//   //                 ]);
//   //               }).toList(),
//   //             ),
//   //           );
//   //         },
//   //       ),
//   //     ],
//   //   );
//   // }

//   // /// Fetch dashboard metrics
//   // Future<Map<String, dynamic>> _fetchDashboardMetrics() async {
//   //   try {
//   //     final querySnapshot =
//   //         await _documentService.firestore.collection('univault').get();
//   //     int totalDocuments = 0;

//   //     for (var doc in querySnapshot.docs) {
//   //       final data = doc.data();
//   //       totalDocuments += (data['totalDocuments'] as int? ?? 0);
//   //     }
//   //     // Fake recent retrievals = 10% of total
//   //     final recentRetrievals = (totalDocuments * 0.1).round();

//   //     return {
//   //       'totalDocuments': totalDocuments,
//   //       'recentRetrievals': recentRetrievals,
//   //     };
//   //   } catch (e) {
//   //     throw Exception('Error fetching dashboard metrics: $e');
//   //   }
//   // }

//   // /// Fetch 3 most recent documents from Firestore
//   // Future<List<DocumentModel>> _fetchRecentDocuments() async {
//   //   try {
//   //     final querySnapshot = await _documentService.firestore
//   //         .collectionGroup('documents')
//   //         .orderBy('timestamp', descending: true)
//   //         .limit(3)
//   //         .get();

//   //     return querySnapshot.docs.map((doc) {
//   //       return DocumentModel.fromMap(doc.id, doc.data());
//   //     }).toList();
//   //   } catch (e) {
//   //     throw Exception('Error fetching recent documents: $e');
//   //   }
//   // }

//   /// Format timestamp
//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);

//     if (difference.inMinutes < 60) {
//       return '${difference.inMinutes} minutes ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} hours ago';
//     } else {
//       return '${difference.inDays} days ago';
//     }
//   }
// }
import 'package:archival_system/src/features/screens/other_screens/document_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/model/document_model.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/sidebar.dart';
import '../other_screens/dcuments/document_screen.dart';
import '../other_screens/document_view_screen.dart';
import '../other_screens/ocr_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color lightblue = Color.fromARGB(255, 132, 132, 240);
  static const Color white = Colors.white;
  static Color blue = Colors.blue.shade700;
  static const Color black = Colors.black;

  final DocumentService _documentService = DocumentService();

  // ----- MOCK DATA (Do not remove, only comment out) -----
//  static const int _mockTotalDocuments = 45;
//  static const int _mockRecentRetrievals = 5;
//  static List<DocumentModel> _mockRecentDocuments = [
//    DocumentModel(
//      id: '1',
//      userName: 'Samuel Adeokun',
//      matricNumber: '220118',
//      level: '300 Level',
//      documentType: 'Transcript',
//      text: 'Sample text',
//      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//      fileUrl: '',
//    ),
//    DocumentModel(
//      id: '2',
//      userName: 'Janet Slyia',
//      matricNumber: '202989',
//      level: '200 Level',
//      documentType: 'Letter',
//      text: 'Sample text',
//      timestamp: DateTime.now().subtract(const Duration(days: 1)),
//      fileUrl: '',
//    ),
//    DocumentModel(
//      id: '3',
//      userName: 'Michael Jonathan',
//      matricNumber: '203323',
//      level: '400 Level',
//      documentType: 'Report',
//      text: 'Sample text',
//      timestamp: DateTime.now().subtract(const Duration(days: 3)),
//      fileUrl: '',
//    ),
//  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Row(
        children: [
          // Sidebar with animation
          Sidebar(
            selectedMenu: 'Overview', // This page is "Overview"
            onMenuSelected: _onSidebarMenuSelected,
          ).animate().fadeIn(duration: 500.ms),
          // Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 16),
                  _buildDashboardMetrics(context)
                      .animate()
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 24),
                  _buildRecentDocumentAccess(context)
                      .animate()
                      .fadeIn(duration: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardMetrics(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDashboardMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading metrics: ${snapshot.error}'));
        }
        final data = snapshot.data ?? {};
        final totalDocuments = data['totalDocuments'] ?? 0;
        final recentRetrievals = data['recentRetrievals'] ?? 0;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            DashboardCard(
              icon: Icons.folder,
              title: 'Total Documents',
              subtitle: '$totalDocuments files stored',
              buttonText: 'View All',
              onPressed: () {
                _showSnack('View All Documents clicked');
              },
            ).animate().fadeIn(duration: 400.ms),
            DashboardCard(
              icon: Icons.refresh,
              title: 'Recent Retrievals',
              subtitle: '$recentRetrievals documents this week',
              buttonText: 'See Details',
              onPressed: () {
                _showSnack('See Recent Retrievals clicked');
              },
            ).animate().fadeIn(duration: 400.ms),
          ],
        );
      },
    );
  }

  Widget _buildRecentDocumentAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Document Access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: black,
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        FutureBuilder<List<DocumentModel>>(
          future: _fetchRecentDocuments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Error loading recent documents: ${snapshot.error}'));
            }
            final documents = snapshot.data ?? [];
            if (documents.isEmpty) {
              return const Center(child: Text('No recent documents found'));
            }
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(
                      label: Text('Document',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('User',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Action',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(
                      label: Text('Timestamp',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('')),
                ],
                rows: documents.map((doc) {
                  return DataRow(cells: [
                    DataCell(Text(doc.documentType.isNotEmpty
                        ? '${doc.documentType}.pdf'
                        : 'Unknown.pdf')),
                    DataCell(Text(doc.userName)),
                    DataCell(TextButton(
                      onPressed: () {
                        _showSnack(
                            'View action for ${doc.documentType} clicked');
                      },
                      child: const Text('View',
                          style: TextStyle(color: Colors.blue)),
                    )),
                    DataCell(Text(_formatTimestamp(doc.timestamp))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          _showSnack(
                              'More options for ${doc.documentType} clicked');
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          },
        ).animate().fadeIn(duration: 400.ms),
      ],
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<Map<String, dynamic>> _fetchDashboardMetrics() async {
    try {
      final querySnapshot =
          await _documentService.firestore.collection('univault').get();
      int totalDocuments = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalDocuments += (data['totalDocuments'] as int? ?? 0);
      }
      final recentRetrievals = (totalDocuments * 0.1).round();
      return {
        'totalDocuments': totalDocuments,
        'recentRetrievals': recentRetrievals
      };
    } catch (e) {
      throw Exception('Error fetching dashboard metrics: $e');
    }
  }

  Future<List<DocumentModel>> _fetchRecentDocuments() async {
    try {
      final querySnapshot = await _documentService.firestore
          .collectionGroup('documents')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching recent documents: $e');
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _onSidebarMenuSelected(String menu) {
    if (menu == 'Overview') {
      // Already on the dashboard.
    } else if (menu == 'Documents') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
      );
      _showSnack('Navigating to Documents screen');
    } else if (menu == 'Users') {
      // TODO: Handle navigation to Users screen.
      // Navigator.push(context, MaterialPageRoute(builder: (_) => UserFolderScreen()));
      // _showSnack('Navigating to Users screen');
    }
  }
}
