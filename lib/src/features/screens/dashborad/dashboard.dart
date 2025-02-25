import 'package:archival_system/src/features/screens/other_screens/document_overview_screen.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Optional: keep an app bar or remove it if you want a full-screen approach
      // appBar: AppBar(
      //   title: const Text('Dashboard Overview'),
      //   centerTitle: true,
      //   backgroundColor: white,
      //   foregroundColor: black,
      //   elevation: 0,
      // ),
      backgroundColor: white,
      body: Row(
        children: [
          // 1) The Sidebar
          Sidebar(
            selectedMenu: 'Overview', // This page is "Overview"
            onMenuSelected: _onSidebarMenuSelected,
          ),
          // 2) Main content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardMetrics(context),
                  const SizedBox(height: 24),
                  Center(child: _buildQuickActions()),
                  const SizedBox(height: 24),
                  _buildRecentDocumentAccess(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle sidebar navigation
  void _onSidebarMenuSelected(String menu) {
    if (menu == 'Overview') {
      // Already on the dashboard, do nothing or pop
    } else if (menu == 'Documents') {
      // TODO: Navigate to a Documents page or screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DocumentOverviewScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Navigate to Documents screen')),
      );
    } else if (menu == 'Users') {
      // TODO: Navigate to a Users page or screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => UserFolderScreen()),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Navigate to Users screen')),
      // );
    }
  }

  /// Dashboard metrics (uses Firestore to fetch data)
  Widget _buildDashboardMetrics(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDashboardMetrics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading metrics'));
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
                // Placeholder for navigation to documents list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View All Documents clicked')),
                );
              },
            ),
            DashboardCard(
              icon: Icons.refresh,
              title: 'Recent Retrievals',
              subtitle: '$recentRetrievals documents this week',
              buttonText: 'See Details',
              onPressed: () {
                // Placeholder for navigation to recent retrievals
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('See Recent Retrievals clicked')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Quick actions section
  Widget _buildQuickActions() {
    return ElevatedButton(
      onPressed: () {
        // Example: navigate to OCR upload screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OcrUploadScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
      ),
      child: const Text('Upload New Document'),
    );
  }

  /// Recent documents table
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
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<DocumentModel>>(
          future: _fetchRecentDocuments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                  child: Text('Error loading recent documents'));
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
                    label: Text(
                      'Document',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'User',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Action',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Timestamp',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(label: Text('')), // For three-dot menu
                ],
                rows: documents.map((doc) {
                  return DataRow(cells: [
                    DataCell(Text(doc.documentType.isNotEmpty
                        ? '${doc.documentType}.pdf'
                        : 'Unknown.pdf')),
                    DataCell(Text(doc.userName)),
                    const DataCell(Text('View')),
                    DataCell(Text(_formatTimestamp(doc.timestamp))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // Placeholder for menu action
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'More options for ${doc.documentType} clicked',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Fetch dashboard metrics
  Future<Map<String, dynamic>> _fetchDashboardMetrics() async {
    try {
      final querySnapshot =
          await _documentService.firestore.collection('univault').get();
      int totalDocuments = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalDocuments += (data['totalDocuments'] as int? ?? 0);
      }
      // Fake recent retrievals = 10% of total
      final recentRetrievals = (totalDocuments * 0.1).round();

      return {
        'totalDocuments': totalDocuments,
        'recentRetrievals': recentRetrievals,
      };
    } catch (e) {
      throw Exception('Error fetching dashboard metrics: $e');
    }
  }

  /// Fetch 3 most recent documents from Firestore
  Future<List<DocumentModel>> _fetchRecentDocuments() async {
    try {
      final querySnapshot = await _documentService.firestore
          .collectionGroup('documents')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      return querySnapshot.docs.map((doc) {
        return DocumentModel.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      throw Exception('Error fetching recent documents: $e');
    }
  }

  /// Format timestamp
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
}
