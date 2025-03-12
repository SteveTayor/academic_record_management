import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/model/document_model.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/sidebar.dart';
import '../other_screens/dcuments/document_detail_screen.dart';
import '../other_screens/dcuments/document_screen.dart';
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
// import 'package:flutter_animate/flutter_animate.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   static const Color lightblue = Color.fromARGB(255, 132, 132, 240);
//   static const Color white = Colors.white;
//   static Color blue = Colors.blue.shade700;
//   static const Color black = Colors.black;
//   // Pagination state
//   int _currentPage = 1;
//   int _rowsPerPage = 8;
//   final DocumentService _documentService = DocumentService();
//   final DocumentNavigationProvider _documentProvider =
//       DocumentNavigationProvider();

//   @override
//   void initState() {
//     super.initState();
//     Provider.of<DocumentNavigationProvider>(context, listen: false)
//         .fetchRecentDocuments(limit: 1000);
//     _loadDashboardData();
//   }

//   Future<void> _loadDashboardData() async {
//     // Fetch the data using the provider
//     // await _documentProvider.fetchRecentDocuments(limit: 3);
//     await _documentProvider.fetchTotalDocumentsCount();
//   }
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   _fetchAllDocuments();
//   // }

//   // Future<void> _fetchAllDocuments() async {
//   //   setState(() {
//   //     _isLoading = true;
//   //     _hasError = false;
//   //   });

//   //   try {
//   //     // Fetch all or a large chunk of documents.
//   //     // If you only want "recent", adjust your Firestore query accordingly.
//   //     final docs = await _documentService.fetchRecentDocuments(limit: 1000);
//   //     setState(() {
//   //       _allDocuments = docs;
//   //     });
//   //   } catch (e) {
//   //     setState(() {
//   //       _hasError = true;
//   //     });
//   //     debugPrint('Error fetching documents: $e');
//   //   } finally {
//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }

//   // Future<List<DocumentModel>> _fetchRecentDocuments() async {
//   //   try {
//   //     // Use the new method from DocumentService
//   //     return await _documentService.fetchRecentDocuments(limit: 3);
//   //   } catch (e) {
//   //     // Show a more helpful error that guides the user
//   //     if (e.toString().contains('index')) {
//   //       final indexUrl = _documentService.getIndexCreationUrl();
//   //       // You could show a dialog here with the URL
//   //       print('Index missing. Create it at: $indexUrl');
//   //     }
//   //     throw Exception('Error fetching recent documents: $e');
//   //   }
//   // }

//   // this helper method to show a dialog when the index is missing
//   void _showIndexMissingDialog(BuildContext context) {
//     final indexUrl = _documentService.getIndexCreationUrl();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Database Index Required'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'This feature requires a special database index. Please create the index by clicking the button below and following the Firebase instructions.',
//             ),
//             const SizedBox(height: 16),
//             SelectableText(
//               indexUrl,
//               style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               // Launch the URL if you have url_launcher package
//               // await launchUrl(Uri.parse(indexUrl));
//               // Or just copy to clipboard
//               await Clipboard.setData(ClipboardData(text: indexUrl));
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('URL copied to clipboard')),
//               );
//               Navigator.pop(context);
//             },
//             child: const Text('Copy URL'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       body: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Sidebar with animation
//           Sidebar(
//             selectedMenu: 'Overview', // This page is "Overview"
//             onMenuSelected: _onSidebarMenuSelected,
//           ).animate().fadeIn(duration: 500.ms),
//           // Main content area
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Dashboard Overview',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: black,
//                     ),
//                   ).animate().fadeIn(duration: 500.ms),
//                   const SizedBox(height: 16),
//                   _buildDashboardMetrics(context)
//                       .animate()
//                       .fadeIn(duration: 500.ms),
//                   const SizedBox(height: 24),
//                   _buildRecentDocumentAccess(context)
//                       .animate()
//                       .fadeIn(duration: 500.ms),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDashboardMetrics(BuildContext context) {
//     return ChangeNotifierProvider.value(
//       value: _documentProvider,
//       child: Consumer<DocumentNavigationProvider>(
//         builder: (context, provider, _) {
//           if (provider.isLoading) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Loading your dashboard data...',
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (provider.error != null) {
//             return Center(
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 width: double.infinity,
//                 constraints: const BoxConstraints(maxWidth: 500),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       color: Colors.red,
//                       size: 60,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Something went wrong',
//                       style: Theme.of(context).textTheme.headlineSmall,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       provider.errorState.message ?? provider.error!,
//                       style: Theme.of(context).textTheme.bodyLarge,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton.icon(
//                           icon: const Icon(Icons.refresh),
//                           label:
//                               Text(provider.errorState.actionLabel ?? 'Retry'),
//                           onPressed: provider.errorState.actionCallback ??
//                               provider.clearError,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[800],
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         OutlinedButton(
//                           child: const Text('Cancel'),
//                           onPressed: () {
//                             provider.clearError();
//                             // Optionally navigate back or to a safe state
//                             // Navigator.of(context).pop();
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//           // return FutureBuilder<Map<String, dynamic>>(
//           //   future: _fetchDashboardMetrics(),
//           //   builder: (context, snapshot) {
//           //     if (snapshot.connectionState == ConnectionState.waiting) {
//           //       return const Center(child: CircularProgressIndicator());
//           //     }
//           //     if (snapshot.hasError) {
//           //       return Center(
//           //           child: Text('Error loading metrics: ${snapshot.error}'));
//           //     }
//           // final data = snapshot.data ?? {};
//           // final totalDocuments = data['totalDocuments'] ?? 0;
//           // final recentRetrievals = data['recentRetrievals'] ?? 0;

//           final totalDocumentsCount = provider.totalDocumentsCount;
//           // Calculate metrics
//           final recentRetrievals = (provider.totalDocumentsCount * 0.1).round();
//           return Wrap(
//             spacing: 16,
//             runSpacing: 16,
//             children: [
//               DashboardCard(
//                 icon: Icons.folder,
//                 title: 'Total Documents',
//                 subtitle: '$totalDocumentsCount files stored',
//                 buttonText: 'View All',
//                 onPressed: () {
//                   _showSnack('View All Documents clicked');
//                 },
//               ).animate().fadeIn(duration: 400.ms),
//               DashboardCard(
//                 icon: Icons.refresh,
//                 title: 'Recent Retrievals',
//                 subtitle: '$recentRetrievals documents this week',
//                 buttonText: 'See Details',
//                 onPressed: () {
//                   _showSnack('See Recent Retrievals clicked');
//                 },
//               ).animate().fadeIn(duration: 400.ms),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRecentDocumentAccess(BuildContext context) {
//     return Consumer<DocumentNavigationProvider>(
//         builder: (context, recentProvider, _) {
//       return SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Recent Document Access',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: black,
//               ),
//             ),
//             const SizedBox(height: 8),

//             // Use provider's state variables instead of local ones
//             if (recentProvider.isLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (recentProvider.error != null)
//               Center(child: Text('Error: ${recentProvider.error}'))
//             else if (recentProvider.recentDocuments.isEmpty)
//               const Center(child: Text('No recent documents found'))
//             else
//               _buildPaginatedTable(context, recentProvider.recentDocuments),
//           ],
//         ),
//       );
//     });
//   }

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
//   //       ).animate().fadeIn(duration: 400.ms),
//   //       const SizedBox(height: 8),
//   //       FutureBuilder<List<DocumentModel>>(
//   //         future: _fetchRecentDocuments(),
//   //         builder: (context, snapshot) {
//   //           if (snapshot.connectionState == ConnectionState.waiting) {
//   //             return const Center(child: CircularProgressIndicator());
//   //           }
//   //           if (snapshot.hasError) {
//   //             // If it's an index issue, show a more helpful message
//   //             if (snapshot.error.toString().contains('index')) {
//   //               return Center(
//   //                 child: Column(
//   //                   mainAxisSize: MainAxisSize.min,
//   //                   children: [
//   //                     const Text('This feature requires a database index'),
//   //                     const SizedBox(height: 12),
//   //                     ElevatedButton(
//   //                       onPressed: () => _showIndexMissingDialog(context),
//   //                       child: const Text('Get Help'),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               );
//   //             }
//   //             return Center(
//   //                 child: Text(
//   //                     'Error loading recent documents: ${snapshot.error}'));
//   //           }
//   //           final documents = snapshot.data ?? [];
//   //           if (documents.isEmpty) {
//   //             return const Center(child: Text('No recent documents found'));
//   //           }
//   //           return SingleChildScrollView(
//   //             scrollDirection: Axis.horizontal,
//   //             child: Container(
//   //               width: MediaQuery.of(context).size.width,
//   //               margin: const EdgeInsets.all(16),
//   //               decoration: BoxDecoration(
//   //                 borderRadius: BorderRadius.circular(8),
//   //                 color: Colors.blueGrey[50],
//   //               ),
//   //               child: DataTable(
//   //                 columnSpacing: 24,
//   //                 columns: const [
//   //                   DataColumn(
//   //                       label: Text('Document',
//   //                           style: TextStyle(fontWeight: FontWeight.bold))),
//   //                   DataColumn(
//   //                       label: Text('User',
//   //                           style: TextStyle(fontWeight: FontWeight.bold))),
//   //                   DataColumn(
//   //                       label: Text('Action',
//   //                           style: TextStyle(fontWeight: FontWeight.bold))),
//   //                   DataColumn(
//   //                       label: Text('Timestamp',
//   //                           style: TextStyle(fontWeight: FontWeight.bold))),
//   //                   DataColumn(label: Text('')),
//   //                 ],
//   //                 rows: documents.map((doc) {
//   //                   return DataRow(cells: [
//   //                     DataCell(Text(doc.documentType.isNotEmpty
//   //                         ? '${doc.documentType}.pdf'
//   //                         : 'Unknown.pdf')),
//   //                     DataCell(Text(doc.userName)),
//   //                     DataCell(TextButton(
//   //                       onPressed: () {
//   //                         _showSnack(
//   //                             'View action for ${doc.documentType} clicked');
//   //                       },
//   //                       child: const Text('View',
//   //                           style: TextStyle(color: Colors.blue)),
//   //                     )),
//   //                     DataCell(Text(_formatTimestamp(doc.timestamp))),
//   //                     DataCell(
//   //                       IconButton(
//   //                         icon: const Icon(Icons.more_vert),
//   //                         onPressed: () {
//   //                           _showSnack(
//   //                               'More options for ${doc.documentType} clicked');
//   //                         },
//   //                       ),
//   //                     ),
//   //                   ]);
//   //                 }).toList(),
//   //               ),
//   //             ),
//   //           );
//   //         },
//   //       ).animate().fadeIn(duration: 400.ms),
//   //     ],
//   //   );
//   // }

//   Widget _buildPaginatedTable(
//       BuildContext context, List<DocumentModel> documents) {
//     // 1. Calculate total pages
//     final totalDocs = documents.length;
//     final totalPages = (totalDocs / _rowsPerPage).ceil();

//     // 2. Determine the slice of documents for current page
//     final startIndex = (_currentPage - 1) * _rowsPerPage;
//     final endIndex = startIndex + _rowsPerPage;
//     final displayedDocs = documents.sublist(
//       startIndex,
//       endIndex > totalDocs ? totalDocs : endIndex,
//     );

//     return Column(
//       children: [
//         // The table
//         SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Container(
//               width: MediaQuery.of(context).size.width - 350,
//               margin: const EdgeInsets.all(16),
//               child: DataTable(
//                 decoration: BoxDecoration(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(15),
//                     topRight: Radius.circular(15),
//                   ),
//                   color: Colors.blueGrey[50],
//                 ),
//                 // headingRowColor: WidgetStatePropertyAll(Colors.blue[600]),
//                 columnSpacing: 24,
//                 columns: const [
//                   DataColumn(
//                     label: Text('Document',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   DataColumn(
//                     label: Text('Student',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   DataColumn(
//                     label: Text('Action',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   DataColumn(
//                     label: Text('Timestamp',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   DataColumn(label: Text('')),
//                 ],
//                 rows: displayedDocs.map((doc) {
//                   return DataRow(cells: [
//                     DataCell(Text(doc.documentType.isNotEmpty
//                         ? '${doc.documentType}.pdf'
//                         : 'Unknown.pdf')),
//                     DataCell(Text(doc.userName)),
//                     DataCell(TextButton(
//                       onPressed: () {
//                         // s_showSnack('View action for ${doc.documentType} clicked');
//                       },
//                       child: const Text('Recently Accessed',
//                           style: TextStyle(color: Colors.purple)),
//                     )),
//                     DataCell(Text(_formatTimestamp(doc.timestamp))),
//                     DataCell(
//                       PopupMenuButton<String>(
//                         icon: const Icon(Icons.more_vert),
//                         onSelected: (value) => _handleMenuSelection(value, doc),
//                         itemBuilder: (BuildContext context) =>
//                             <PopupMenuEntry<String>>[
//                           const PopupMenuItem<String>(
//                             value: 'view',
//                             child: Text('View Details'),
//                           ),
//                           const PopupMenuItem<String>(
//                             value: 'edit',
//                             child: Text('Edit'),
//                           ),
//                           const PopupMenuItem<String>(
//                             value: 'delete',
//                             child: Text('Delete'),
//                           ),
//                           if (doc.fileUrl.isNotEmpty)
//                             const PopupMenuItem<String>(
//                               value: 'download',
//                               child: Text('Download'),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ]);
//                 }).toList(),
//               ),
//             ),
//           ),
//         ),

//         // The pagination controls
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               // Rows per page dropdown
//               const Text('Rows per page: '),
//               DropdownButton<int>(
//                 value: _rowsPerPage,
//                 items: [8, 20, 50, 100].map((val) {
//                   return DropdownMenuItem<int>(
//                     value: val,
//                     child: Text('$val'),
//                   );
//                 }).toList(),
//                 onChanged: (val) {
//                   if (val != null) {
//                     setState(() {
//                       _rowsPerPage = val;
//                       _currentPage = 1; // Reset to first page
//                     });
//                   }
//                 },
//               ),

//               const SizedBox(width: 24),

//               // Previous page
//               IconButton(
//                 icon: const Icon(Icons.chevron_left),
//                 onPressed: _currentPage > 1
//                     ? () {
//                         setState(() {
//                           _currentPage--;
//                         });
//                       }
//                     : null,
//               ),

//               // Page indicator
//               Text('$_currentPage of $totalPages'),

//               // Next page
//               IconButton(
//                 icon: const Icon(Icons.chevron_right),
//                 onPressed: _currentPage < totalPages
//                     ? () {
//                         setState(() {
//                           _currentPage++;
//                         });
//                       }
//                     : null,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// Handle the selected menu option
//   void _handleMenuSelection(String value, DocumentModel doc) {
//     final provider =
//         Provider.of<DocumentNavigationProvider>(context, listen: false);
//     switch (value) {
//       case 'view':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => DocumentDetailScreen(document: doc)),
//         );
//         break;
//       case 'edit':
//         _showSnack('Edit document ${doc.id} - Functionality to be implemented');
//         // TODO: Navigate to an EditDocumentScreen when implemented
//         break;
//       case 'delete':
//         _showDeleteConfirmation(doc, provider);
//         break;
//       case 'download':
//         _downloadDocument(doc.fileUrl);
//         break;
//     }
//   }

//   /// Show a confirmation dialog before deleting
//   void _showDeleteConfirmation(
//       DocumentModel doc, DocumentNavigationProvider provider) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete ${doc.documentType}?'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: const Text('Delete'),
//               onPressed: () async {
//                 try {
//                   await provider.deleteDocument(doc);
//                   _showSnack('Document deleted successfully');
//                 } catch (e) {
//                   _showSnack('Error deleting document: $e');
//                 }
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Placeholder for downloading a document
//   void _downloadDocument(String url) {
//     _showSnack('Downloading $url');
//     // TODO: Implement actual download logic, e.g., using url_launcher
//     // For web, you could use: html.window.open(url, '_blank');
//   }

//   // void _showSnack(String message) {
//   //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   // }

//   void _showSnack(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   // Future<Map<String, dynamic>> _fetchDashboardMetrics() async {
//   //   try {
//   //     final totalDocuments = await _documentService.fetchTotalDocumentsCount();
//   //     final recentRetrievals = (totalDocuments * 0.1).round();
//   //     return {
//   //       'totalDocuments': totalDocuments,
//   //       'recentRetrievals': recentRetrievals,
//   //     };
//   //   } catch (e) {
//   //     throw Exception("Error fetching dashboard metrics: $e");
//   //   }
//   // }

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

//   void _onSidebarMenuSelected(String menu) {
//     if (menu == 'Overview') {
//       // Already on the dashboard.
//     } else if (menu == 'Documents') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
//       );
//       _showSnack('Navigating to Documents screen');
//     } else if (menu == 'Users') {
//       // TODO: Handle navigation to Users screen.
//       // Navigator.push(context, MaterialPageRoute(builder: (_) => UserFolderScreen()));
// // _showSnack('Navigating to Users screen');
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/model/document_model.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/sidebar.dart';
import '../other_screens/dcuments/document_detail_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color lightblue = Color.fromARGB(255, 132, 132, 240);
  static const Color white = Colors.white;
  static Color blue = Colors.blue.shade700;
  static const Color black = Colors.black;

  // Pagination and lazy loading parameters
  final int _currentPage = 1;
  final int _rowsPerPage = 8;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  final DocumentService _documentService = DocumentService();
  final DocumentNavigationProvider _documentProvider =
      DocumentNavigationProvider();

  @override
  void initState() {
    super.initState();
    // Initialize data loading
    _initializeData();

    // Setup scroll listener for lazy loading
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _initializeData() async {
    final provider =
        Provider.of<DocumentNavigationProvider>(context, listen: false);
    // Initial fetch with a smaller batch size for faster initial load
    await provider.fetchRecentDocuments(limit: _rowsPerPage);
    await provider.fetchTotalDocumentsCount();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      _loadMoreDocuments();
    }
  }

  Future<void> _loadMoreDocuments() async {
    final provider =
        Provider.of<DocumentNavigationProvider>(context, listen: false);

    if (provider.isLoading ||
        provider.recentDocuments.length >= provider.totalDocumentsCount) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      await provider.fetchMoreDocuments(
        startAfter: provider.recentDocuments.last,
        limit: _rowsPerPage,
      );
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar with animation
          Sidebar(
            selectedMenu: 'Overview',
            onMenuSelected: _onSidebarMenuSelected,
          ).animate().fadeIn(duration: 500.ms),

          // Main content area
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
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
                        const Text(
                          'Recent Document Access',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // Document list with lazy loading
                _buildLazyLoadingDocumentList(),

                // Loading indicator at bottom for lazy loading
                SliverToBoxAdapter(
                  child: _isLoadingMore
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardMetrics(BuildContext context) {
    return Consumer<DocumentNavigationProvider>(
      builder: (context, provider, _) {
        // Show skeleton loading while data is loading
        if (provider.isLoading) {
          return _buildMetricsSkeleton();
        }

        if (provider.error != null) {
          return _buildErrorState(provider);
        }

        final totalDocumentsCount = provider.totalDocumentsCount;
        final recentRetrievals = (provider.totalDocumentsCount * 0.1).round();

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            DashboardCard(
              icon: Icons.folder,
              title: 'Total Documents',
              subtitle: '$totalDocumentsCount files stored',
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

  Widget _buildMetricsSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildSkeletonCard(),
          _buildSkeletonCard(),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildErrorState(DocumentNavigationProvider provider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorState.message ?? provider.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  label: Text(provider.errorState.actionLabel ?? 'Retry'),
                  onPressed:
                      provider.errorState.actionCallback ?? provider.clearError,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    provider.clearError();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLazyLoadingDocumentList() {
    return Consumer<DocumentNavigationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.recentDocuments.isEmpty) {
          return SliverToBoxAdapter(child: _buildDocumentListSkeleton());
        }

        if (provider.error != null && provider.recentDocuments.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${provider.error}')),
          );
        }

        if (provider.recentDocuments.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No recent documents found')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blueGrey[50],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: DataTable(
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(
                          label: Text('Document',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Student',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Action',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(
                          label: Text('Timestamp',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DataColumn(label: Text('')),
                      ],
                      rows: provider.recentDocuments.map((doc) {
                        return DataRow(cells: [
                          DataCell(Text(doc.documentType.isNotEmpty
                              ? '${doc.documentType}.pdf'
                              : 'Unknown.pdf')),
                          DataCell(Text(doc.userName)),
                          DataCell(TextButton(
                            onPressed: () {},
                            child: const Text('Recently Accessed',
                                style: TextStyle(color: Colors.purple)),
                          )),
                          DataCell(Text(_formatTimestamp(doc.timestamp))),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) =>
                                  _handleMenuSelection(value, doc),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                                if (doc.fileUrl.isNotEmpty)
                                  const PopupMenuItem<String>(
                                    value: 'download',
                                    child: Text('Download'),
                                  ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentListSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
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

  void _handleMenuSelection(String value, DocumentModel doc) {
    final provider =
        Provider.of<DocumentNavigationProvider>(context, listen: false);
    switch (value) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DocumentDetailScreen(document: doc)),
        );
        break;
      case 'edit':
        _showSnack('Edit document ${doc.id} - Functionality to be implemented');
        break;
      case 'delete':
        _showDeleteConfirmation(doc, provider);
        break;
      case 'download':
        _downloadDocument(doc.fileUrl);
        break;
    }
  }

  void _showDeleteConfirmation(
      DocumentModel doc, DocumentNavigationProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${doc.documentType}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await provider.deleteDocument(doc);
                  _showSnack('Document deleted successfully');
                } catch (e) {
                  _showSnack('Error deleting document: $e');
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _downloadDocument(String url) {
    _showSnack('Downloading $url');
    // TODO: Implement actual download logic
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      // TODO: Handle navigation to Users screen
      _showSnack('Users screen to be implemented');
    }
  }
}
