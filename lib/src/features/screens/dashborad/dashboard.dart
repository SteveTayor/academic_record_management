import 'package:archival_system/src/features/screens/other_screens/ocr_screen.dart';
import 'package:flutter/material.dart';
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
              _buildDashboardMetrics(),
              const SizedBox(height: 24),
              Center(child: _buildQuickActions()),
              const SizedBox(height: 24),
              _buildRecentDocumentAccess(),
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
            // ListTile(
            //   leading: const Icon(Icons.lock, color: black),
            //   title: const Text('Access Logs', style: TextStyle(color: black)),
            //   onTap: () => Navigator.pop(context), // Placeholder navigation
            // ),
            // ExpansionTile(
            //   leading: const Icon(Icons.bar_chart, color: black),
            //   title: const Text('Reports', style: TextStyle(color: black)),
            //   children: [
            //     ListTile(
            //       title: const Text('Security Report', style: TextStyle(color: black)),
            //       onTap: () => Navigator.pop(context), // Placeholder navigation
            //     ),
            //     ListTile(
            //       title: const Text('Usage Analytics', style: TextStyle(color: black)),
            //       onTap: () => Navigator.pop(context), // Placeholder navigation
            //     ),
            //   ],
            // ),
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
                        style: TextStyle(fontWeight: FontWeight.bold, color: black),
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

  // Dashboard metrics section
  Widget _buildDashboardMetrics() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: const [
        DashboardCard(
          icon: Icons.folder,
          title: 'Total Documents',
          subtitle: '1,234 files stored',
          buttonText: 'View All',
        ),
        DashboardCard(
          icon: Icons.refresh,
          title: 'Recent Retrievals',
          subtitle: '156 documents this week',
          buttonText: 'See Details',
        ),
        DashboardCard(
          icon: Icons.security,
          title: 'Security Alerts',
          subtitle: '3 suspicious activities',
          buttonText: 'Review',
        ),
        DashboardCard(
          icon: Icons.analytics,
          title: 'Access Summary',
          subtitle: '892 total accesses today',
          buttonText: 'View Logs',
        ),
      ],
    );
  }

  // Quick actions section
  Widget _buildQuickActions() {
    return ElevatedButton(
      onPressed: () {
        // Placeholder for upload action
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Upload New Document clicked')),
        // );
        Navigator.push(context, MaterialPageRoute(builder: (context) => OcrUploadScreen()));
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

  // Recent document access table
  Widget _buildRecentDocumentAccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Document Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: black),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 24,
            columns: const [
              DataColumn(
                label: Text('Document', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('User', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(label: Text('')), // For three-dot menu
            ],
            rows: [
              DataRow(cells: [
                const DataCell(Text('Research Paper.pdf')),
                const DataCell(Text('John Doe')),
                const DataCell(Text('View')),
                const DataCell(Text('2 minutes ago')),
                DataCell(IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Placeholder for menu action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('More options clicked')),
                    );
                  },
                )),
              ]),
              DataRow(cells: [
                const DataCell(Text('Thesis Draft.docx')),
                const DataCell(Text('Jane Smith')),
                const DataCell(Text('Edit')),
                const DataCell(Text('15 minutes ago')),
                DataCell(IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Placeholder for menu action
                  },
                )),
              ]),
              DataRow(cells: [
                const DataCell(Text('Lab Results.xlsx')),
                const DataCell(Text('Mike Johnson')),
                const DataCell(Text('View')),
                const DataCell(Text('1 hour ago')),
                DataCell(IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Placeholder for menu action
                  },
                )),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}