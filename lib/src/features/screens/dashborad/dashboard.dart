import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/service/document_service.dart';
import '../../widgets/dashboard_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Overview'),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Metrics
            StreamBuilder(
              stream: _documentService.getDashboardStats(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final totalDocuments = data['total_documents'] ?? 0;
                final weeklyRetrievals = data['weekly_retrievals'] ?? 0;

                return Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        icon: Icons.folder,
                        title: 'Total Documents',
                        subtitle: '$totalDocuments files stored',
                        buttonText: 'View All',
                        onPressed: () {
                          // Navigate to documents page (placeholder)
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardCard(
                        icon: Icons.refresh,
                        title: 'Recent Retrievals',
                        subtitle: '$weeklyRetrievals documents this week',
                        buttonText: 'See Details',
                        onPressed: () {
                          // Show details (placeholder)
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Upload new document (placeholder)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Upload New Document'),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Document Access
            const Text(
              'Recent Document Access',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder(
                stream: _documentService.getRecentDocuments(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unknown';
                      final user = data['last_accessed_by'] ?? 'Unknown';
                      final action = data['action'] ?? 'Unknown';
                      final time =
                          (data['last_accessed'] as Timestamp?)?.toDate() ??
                              DateTime.now();
                      final timeAgo = timeago.format(time);

                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(name),
                        subtitle: Text('$user • $action • $timeAgo'),
                        trailing: const Icon(Icons.more_vert),
                        onTap: () {
                          // Handle tap (placeholder)
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sidebar Drawer
  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
            ),
            child: Row(
              children: [
                const Text(
                  'UniValut',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.add, color: Colors.black),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            selectedTileColor: Colors.deepPurple.shade50,
            onTap: () {
              Navigator.pop(context); // Stay on dashboard
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Documents'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to documents page (placeholder)
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to users page (placeholder)
            },
          ),
          const Spacer(),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null ? const Icon(Icons.person) : null,
            ),
            title: Text(user?.displayName ?? 'Admin User'),
            subtitle: const Text('System Administrator'),
          ),
        ],
      ),
    );
  }
}