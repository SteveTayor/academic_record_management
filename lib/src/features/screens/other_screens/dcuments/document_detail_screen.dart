import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/model/document_model.dart';

class DocumentDetailScreen extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.documentType),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _handleDownload(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDocumentInfoCard(),
            const SizedBox(height: 20),
            _buildStructuredDataSection(),
            const SizedBox(height: 20),
            _buildRawTextSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentInfoCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Document Type:', document.documentType),
            _buildInfoRow('Matric Number:', document.matricNumber),
            _buildInfoRow('Academic Level:', document.level),
            _buildInfoRow('Processed Date:', _formatDate(document.timestamp)),
            _buildInfoRow('Structured Data:',
                document.structuredData != null ? 'Available' : 'Not Available',
                icon: document.structuredData != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error_outline, color: Colors.orange)),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredDataSection() {
    if (document.structuredData == null) return const SizedBox();

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Structured Data',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            if (document.documentType == 'Transcript') _buildTranscriptView(),
            if (document.documentType == 'Letter') _buildLetterView(),
            if (!['Transcript', 'Letter'].contains(document.documentType))
              _buildGenericStructuredView(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericStructuredView() {
    if (document.structuredData == null || document.structuredData!.isEmpty) {
      return const ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('No structured data available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Document Structure',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...document.structuredData!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    '${entry.key}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _renderStructuredValue(entry.value),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _renderStructuredValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...value.entries.map((subEntry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subEntry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(child: _renderStructuredValue(subEntry.value)),
                  ],
                ),
              )),
        ],
      );
    }

    if (value is List<dynamic>) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var item in value)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: _renderStructuredValue(item)),
        ],
      );
    }

    return Text(
      value.toString(),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildTranscriptView() {
    final student = document.structuredData!['student'] as Map<String, dynamic>;
    final transcript =
        document.structuredData!['transcript'] as Map<String, dynamic>;
    final courses = document.structuredData!['courses'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Student Information'),
        _buildInfoRow('Name:', student['name'] ?? 'N/A'),
        _buildInfoRow('Course of Study:', student['courseOfStudy'] ?? 'N/A'),
        _buildInfoRow('Faculty:', student['faculty'] ?? 'N/A'),
        const SizedBox(height: 16),
        _buildSectionTitle('Academic Summary'),
        _buildInfoRow('Cumulative GPA:',
            transcript['cumulativeGpa']?.toString() ?? 'N/A'),
        _buildInfoRow('Total Units:',
            transcript['cumulativeUnitsRegistered']?.toString() ?? 'N/A'),
        const SizedBox(height: 16),
        _buildSectionTitle('Courses'),
        ...courses.map((course) => _buildCourseTile(course)),
      ],
    );
  }

  Widget _buildLetterView() {
    final letterData = document.structuredData!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('From:', letterData['from'] ?? 'Unknown'),
        _buildInfoRow('To:', letterData['to'] ?? 'Unknown'),
        _buildInfoRow('Date:', letterData['date'] ?? 'Unknown'),
        const SizedBox(height: 16),
        _buildSectionTitle('Content'),
        Text(letterData['body'] ?? ''),
      ],
    );
  }

  Widget _buildRawTextSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Extracted Text',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            SelectableText(
              document.text,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
          if (icon != null) icon,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildCourseTile(Map<String, dynamic> course) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.class_outlined),
      title: Text(course['courseCode'] ?? 'Unknown Course'),
      subtitle: Text(course['description'] ?? ''),
      trailing: Chip(
        label: Text('${course['gradePoint'] ?? 'N/A'} GP'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }

  void _handleDownload(BuildContext context) {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Download functionality not implemented yet')),
    );
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
