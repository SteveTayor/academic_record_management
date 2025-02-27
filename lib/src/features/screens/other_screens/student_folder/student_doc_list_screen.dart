import 'package:flutter/material.dart';

import '../../../../core/model/document_model.dart';
import '../../../../core/service/document_service.dart';
import '../dcuments/document_detail_screen.dart';

class DocumentListScreen extends StatelessWidget {
  final String matricNumber;
  final String level;
  final DocumentService _documentService = DocumentService();

  DocumentListScreen({
    required this.matricNumber,
    required this.level,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Documents for $level')),
      body: FutureBuilder<List<DocumentModel>>(
        future: _documentService.fetchDocuments(matricNumber, level: level),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final documents = snapshot.data ?? [];
          if (documents.isEmpty) {
            return const Center(child: Text('No documents found.'));
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(document.id),
                subtitle: Text(document.documentType),
                onTap: () {
                  // Navigate to the DocumentDetailScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentDetailScreen(document: document),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
