import 'package:flutter/material.dart';

import '../model/document_model.dart';
import '../service/document_service.dart';

// class DocumentProvider extends ChangeNotifier {
//   final DocumentService _documentService = DocumentService();

//   List<Map<String, String>> _students = [];
//   List<String> _levels = [];
//   List<DocumentModel> _documents = [];

//   List<Map<String, String>> get students => _students;
//   List<String> get levels => _levels;
//   List<DocumentModel> get documents => _documents;

//   Future<void> loadStudents() async {
//     _students = await _documentService.fetchAllUsers();
//     notifyListeners();
//   }

//   Future<void> loadLevels(String matricNumber) async {
//     _levels = await _documentService.fetchLevelsForUser(matricNumber);
//     notifyListeners();
//   }

//   Future<void> loadDocuments(String matricNumber, String level) async {
//     _documents =
//         await _documentService.fetchDocuments(matricNumber, level: level);
//     notifyListeners();
//   }
// }
// DocumentNavigationProvider.dart
class DocumentNavigationProvider extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();

  List<Map<String, String>>? _students;
  List<String>? _currentLevels;
  List<DocumentModel>? _currentDocuments;
  String? _currentMatricNumber;
  String? _currentLevel;

  List<Map<String, String>>? get students => _students;
  List<String>? get currentLevels => _currentLevels;
  List<DocumentModel>? get currentDocuments => _currentDocuments;
  String? get currentMatricNumber => _currentMatricNumber;
  String? get currentLevel => _currentLevel;

  Future<void> loadStudents() async {
    try {
      _students = await _documentService.fetchAllUsers();
      notifyListeners();
    } catch (e) {
      print('Error loading students: $e');
      _students = [];
      notifyListeners();
    }
  }

  Future<void> selectStudent(String matricNumber) async {
    _currentMatricNumber = matricNumber;
    _currentLevel = null;
    _currentDocuments = null;

    try {
      _currentLevels = await _documentService.fetchLevelsForUser(matricNumber);
      notifyListeners();
    } catch (e) {
      print('Error loading levels: $e');
      _currentLevels = [];
      notifyListeners();
    }
  }

  Future<void> selectLevel(String level) async {
    if (_currentMatricNumber == null) return;

    _currentLevel = level;

    try {
      _currentDocuments = await _documentService
          .fetchDocuments(_currentMatricNumber!, level: level);
      notifyListeners();
    } catch (e) {
      print('Error loading documents: $e');
      _currentDocuments = [];
      notifyListeners();
    }
  }

  void clearNavigation() {
    _currentMatricNumber = null;
    _currentLevel = null;
    _currentLevels = null;
    _currentDocuments = null;
    notifyListeners();
  }
}
