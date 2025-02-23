import 'package:archival_system/src/features/screens/other_screens/ocr_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/model/document_model.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/dashboard_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Color constants
  static const Color lightPurple = Color(0xFFE6E6FA);
  static const Color white = Colors.white;
  static const Color blue = Colors.blue;
  static const Color black = Colors.black;

  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        centerTitle: true,
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDashboardMetrics(context),
              const SizedBox(height: 24),
              Center(child: _buildQuickActions()),
              const SizedBox(height: 24),
              _buildRecentDocumentAccess(context),
            ],
          ),
        ),
      ),
    );
  }

  // Sidebar navigation menu
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: lightPurple,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Row(
                children: [
                  Text(
                    'UniVault',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.add, color: black),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: black),
              title: const Text('Dashboard', style: TextStyle(color: black)),
              selected: true,
              selectedTileColor: Colors.deepPurple.shade100,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.folder, color: black),
              title: const Text('Documents', style: TextStyle(color: black)),
              onTap: () => Navigator.pop(context), // Placeholder navigation
            ),
            ListTile(
              leading: const Icon(Icons.people, color: black),
              title: const Text('Users', style: TextStyle(color: black)),
              onTap: () => Navigator.pop(context), // Placeholder navigation
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(Icons.person, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin User',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: black),
                      ),
                      Text(
                        'System Administrator',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard metrics section (dynamic data from Firestore)
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

  // Quick actions section
  Widget _buildQuickActions() {
    return ElevatedButton(
      onPressed: () {
        // Placeholder for upload action (navigate to OCR upload screen)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload New Document clicked')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return OcrUploadScreen();
        }));
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

  // Recent document access table (dynamic data from Firestore)
  Widget _buildRecentDocumentAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Document Access',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: black),
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
                    label: Text('Document',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('User',
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
                    DataCell(IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        // Placeholder for menu action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'More options for ${doc.documentType} clicked')),
                        );
                      },
                    )),
                  ]);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper method to fetch dashboard metrics from Firestore
  Future<Map<String, dynamic>> _fetchDashboardMetrics() async {
    try {
      // Fetch total documents (sum of totalDocuments for all students)
      final querySnapshot =
          await _documentService.firestore.collection('univault').get();
      int totalDocuments = 0;
      int recentRetrievals = 0; // Placeholder for recent retrievals logic

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalDocuments += (data['totalDocuments'] as int? ?? 0);
      }

      // Simulate recent retrievals (replace with actual logic if available in Firestore)
      // For now, assume recent retrievals are 10% of total documents
      recentRetrievals = (totalDocuments * 0.1).round();

      return {
        'totalDocuments': totalDocuments,
        'recentRetrievals': recentRetrievals,
      };
    } catch (e) {
      throw Exception('Error fetching dashboard metrics: $e');
    }
  }

  // Helper method to fetch recent documents from Firestore
  Future<List<DocumentModel>> _fetchRecentDocuments() async {
    try {
      // Fetch the 3 most recent documents across all students (ordered by timestamp)
      final querySnapshot = await _documentService.firestore
          .collectionGroup('documents')
          .orderBy('timestamp', descending: true)
          .limit(3)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              DocumentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching recent documents: $e');
    }
  }

  // Helper method to format timestamp for display
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
