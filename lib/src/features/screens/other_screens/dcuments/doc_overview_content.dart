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
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents > Overview',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildHeaderCards(),
          const SizedBox(height: 24),
          _buildRecentDocumentsTable(),
        ],
      ),
    );
  }

  Widget _buildHeaderCards() {
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
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
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocumentsTable() {
    final documents = [
      {
        'fileName': 'Invoice.pdf',
        'status': 'OCR Complete',
        'category': 'Finance',
        'date': '2024-01-20'
      },
      {
        'fileName': 'Contract.pdf',
        'status': 'Processing',
        'category': 'Legal',
        'date': '2024-01-19'
      },
      {
        'fileName': 'Report.pdf',
        'status': 'Queued',
        'category': 'Operations',
        'date': '2024-01-18'
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
