// Modified OverviewContent widget
import 'package:flutter/material.dart';
import '../../../../core/service/document_service.dart';
import '../student_folder/stu_folder.dart';

class OverviewContent extends StatelessWidget {
  final VoidCallback onOcrUploadPressed;
  final VoidCallback onSearchPressed;

  OverviewContent({
    super.key,
    required this.onOcrUploadPressed,
    required this.onSearchPressed,
  });

  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documents > Overview',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
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
    // Keep your existing _buildHeaderCards implementation
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.text_snippet,
            title: 'OCR Processing',
            description:
                'Convert scanned documents into searchable text using OCR technology',
            buttonText: 'Process Documents',
            onPressed: onOcrUploadPressed,
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
            onPressed: onSearchPressed,
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
    // Keep your existing _buildInfoCard implementation
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
            child: FutureBuilder<List<Map<String, String>>>(
              future: _documentService.fetchAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No students found'));
                }

                final students = snapshot.data!;
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
                    rows: students.map((student) {
                      return DataRow(
                        cells: [
                          DataCell(Text(student['name']!)),
                          DataCell(Text(student['matricNumber']!)),
                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserFolderScreen(
                                      userName: student['name']!,
                                      matricNumber: student['matricNumber']!,
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
