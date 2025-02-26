import 'package:flutter/material.dart';

class OverviewContent extends StatelessWidget {
  final VoidCallback onOcrUploadPressed;
  final VoidCallback onSearchPressed;

  const OverviewContent({
    Key? key,
    required this.onOcrUploadPressed,
    required this.onSearchPressed,
  }) : super(key: key);

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
            _buildRecentDocumentsTable(context),
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

  Widget _buildRecentDocumentsTable(BuildContext context) {
    final documents = [
      {
        'fileName': 'Transcript.pdf',
        'status': 'Processed',
        'category': '300 Level',
        'date': '2 hours ago'
      },
      {
        'fileName': 'Letter.pdf',
        'status': 'Processed',
        'category': '200 Level',
        'date': '1 day ago'
      },
      {
        'fileName': 'Report.pdf',
        'status': 'Processed',
        'category': '400 Level',
        'date': '3 days ago'
      },
    ];

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('File Name')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: documents.map((doc) {
                  return DataRow(
                    cells: [
                      DataCell(Text(doc['fileName']!)),
                      DataCell(Text(doc['status']!)),
                      DataCell(Text(doc['category']!)),
                      DataCell(Text(doc['date']!)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => print('Edit ${doc['fileName']}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  print('Delete ${doc['fileName']}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
