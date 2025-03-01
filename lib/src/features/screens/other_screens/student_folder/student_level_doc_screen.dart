// New LevelDocumentsScreen
import 'package:flutter/material.dart';
import '../../../../core/model/document_model.dart';
import '../../../../core/service/document_service.dart';
import '../dcuments/document_detail_screen.dart';

class LevelDocumentsScreen extends StatelessWidget {
  final String userName;
  final String matricNumber;
  final String level;

  LevelDocumentsScreen({
    required this.userName,
    required this.matricNumber,
    required this.level,
    super.key,
  });

  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('$level Documents'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumb(context),
            _buildTitle(),
            _buildDocumentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Back to Levels',
                style: TextStyle(color: Colors.blue)),
          ),
          const Icon(Icons.chevron_right),
          Text('$userName - $level'),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        '$level Documents',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Expanded(
      child: FutureBuilder<List<DocumentModel>>(
        future: _documentService.fetchDocuments(matricNumber, level: level),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No documents found for this level'));
          }

          final documents = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: _getDocumentIcon(document.documentType),
                  title: Text(document.documentType,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('Processed: ${_formatDate(document.timestamp)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentDetailScreen(
                          document: document,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getDocumentIcon(String documentType) {
    IconData iconData;
    Color iconColor;

    switch (documentType.toLowerCase()) {
      case 'transcript':
        iconData = Icons.school;
        iconColor = Colors.blue;
        break;
      case 'letter':
        iconData = Icons.mail;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.description;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor, size: 40);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
