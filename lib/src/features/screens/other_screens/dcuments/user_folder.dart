import 'package:flutter/material.dart';

import '../../../../core/model/document_model.dart';
import '../../../../core/service/document_service.dart';
import '../../../widgets/doc_item.dart';
import '../../../widgets/sidebar.dart';

class UserFolderScreen extends StatelessWidget {
  final String userName;
  final String matricNumber;

  UserFolderScreen({
    required this.userName,
    required this.matricNumber,
    super.key,
  });

  final DocumentService _documentService = DocumentService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedMenu: 'Documents',
            onMenuSelected: (String) {},
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBreadcrumb(context),
                _buildTitle(),
                _buildDocumentList(),
              ],
            ),
          ),
        ],
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
            child: const Text('Main Folders',
                style: TextStyle(color: Colors.blue)),
          ),
          const Icon(Icons.chevron_right),
          Text('$userName ($matricNumber)'),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'User Documents',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDocumentList() {
    return Expanded(
      child: FutureBuilder<List<DocumentModel>>(
        future: _documentService.fetchDocumentsByUser(matricNumber),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final documents = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: documents.length,
            itemBuilder: (context, index) => DocumentItem(
              document: documents[index],
            ),
          );
        },
      ),
    );
  }
}
