import 'package:flutter/material.dart';

import '../model/document_model.dart';
import '../service/document_service.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();

  List<Map<String, String>> _students = [];
  List<String> _levels = [];
  List<DocumentModel> _documents = [];

  List<Map<String, String>> get students => _students;
  List<String> get levels => _levels;
  List<DocumentModel> get documents => _documents;

  Future<void> loadStudents() async {
    _students = await _documentService.fetchAllUsers();
    notifyListeners();
  }

  Future<void> loadLevels(String matricNumber) async {
    _levels = await _documentService.fetchLevelsForUser(matricNumber);
    notifyListeners();
  }

  Future<void> loadDocuments(String matricNumber, String level) async {
    _documents =
        await _documentService.fetchDocuments(matricNumber, level: level);
    notifyListeners();
  }
}
