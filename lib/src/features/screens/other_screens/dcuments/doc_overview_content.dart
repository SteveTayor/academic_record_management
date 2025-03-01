import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/document_provider.dart';
import '../student_folder/stu_folder.dart';

class OverviewContent extends StatefulWidget {
  final VoidCallback onOcrUploadPressed;
  final VoidCallback onSearchPressed;

  const OverviewContent({
    Key? key,
    required this.onOcrUploadPressed,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  State<OverviewContent> createState() => _OverviewContentState();
}

class _OverviewContentState extends State<OverviewContent> {
  @override
  void initState() {
    super.initState();
    // Fetch data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentNavigationProvider>(context, listen: false)
          .fetchAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Documents',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const Icon(Icons.chevron_right),
                const Text('Overview'),
              ],
            ),
            // const Text(
            //   'Documents > Overview',
            //   style: TextStyle(color: Colors.grey, fontSize: 14),
            // ),
            const SizedBox(height: 16),
            _buildHeaderCards(context),
            const SizedBox(height: 24),
            _buildStudentsTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.text_snippet,
            title: 'OCR Processing',
            description:
                'Convert scanned documents into searchable text using OCR technology',
            buttonText: 'Process Documents',
            onPressed: widget.onOcrUploadPressed,
            context: context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.search,
            title: 'Document Search',
            description:
                'Search through processed documents using keywords and filters',
            buttonText: 'Search Documents',
            onPressed: widget.onSearchPressed,
            context: context,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: Colors.blue),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTable(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Student Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            // Use Consumer to listen to provider changes
            child: Consumer<DocumentNavigationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearError();
                            provider.fetchAllUsers();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final users = provider.users;
                if (users.isEmpty) {
                  return const Center(child: Text('No students found'));
                }

                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Student Name')),
                      DataColumn(label: Text('Matric Number')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: users.map((student) {
                      return DataRow(
                        cells: [
                          DataCell(Text(student['name'] ?? 'Unknown')),
                          DataCell(Text(student['matricNumber'] ?? 'Unknown')),
                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                // Pre-fetch documents for this user
                                provider.fetchDocumentsByUser(
                                    student['matricNumber'] ?? '');

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserFolderScreen(
                                      userName: student['name'] ?? 'Unknown',
                                      matricNumber:
                                          student['matricNumber'] ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View Folders'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
