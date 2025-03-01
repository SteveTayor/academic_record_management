import 'package:flutter/material.dart';

import '../model/document_model.dart';
import '../service/document_service.dart';

class DocumentNavigationProvider extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  // State variables
  List<Map<String, String>> _users = [];
  List<DocumentModel> _documents = [];
  List<DocumentModel> _recentDocuments = [];
  List<DocumentModel> _searchResults = [];
  final Map<String, List<String>> _levelsCache = {};
  List<DocumentModel> _recentlySearchedDocuments = [];
  int _totalDocumentsCount = 0;
  bool _isLoading = false;
  String? _error;

  // Pagination for search results
  bool _hasMoreSearchResults = true;
  String? _lastDocumentId;

  // Getters
  List<Map<String, String>> get users => _users;
  List<DocumentModel> get documents => _documents;
  List<DocumentModel> get recentDocuments => _recentDocuments;
  List<DocumentModel> get recentlySearchedDocuments =>
      _recentlySearchedDocuments;
  List<DocumentModel> get searchResults => _searchResults;
  int get totalDocumentsCount => _totalDocumentsCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreSearchResults => _hasMoreSearchResults;

  // Fetch all users from Firestore
  Future<void> fetchAllUsers() async {
    try {
      _setLoading(true);
      _users = await _documentService.fetchAllUsers();
      _setLoading(false);
    } catch (e) {
      _handleError('Error fetching users: $e');
    }
  }

  // Fetch levels for a specific user
  Future<List<String>> fetchLevelsForUser(String matricNumber) async {
    try {
      // Check cache first
      if (_levelsCache.containsKey(matricNumber)) {
        return _levelsCache[matricNumber]!;
      }

      _setLoading(true);
      final levels = await _documentService.fetchLevelsForUser(matricNumber);
      _levelsCache[matricNumber] = levels;
      _setLoading(false);
      return levels;
    } catch (e) {
      _handleError('Error fetching levels: $e');
      return [];
    }
  }

  // Fetch documents for a specific user
  Future<void> fetchDocumentsByUser(String matricNumber) async {
    try {
      _setLoading(true);
      _documents = await _documentService.fetchDocumentsByUser(matricNumber);
      _setLoading(false);
    } catch (e) {
      _handleError('Error fetching documents: $e');
    }
  }

  // Fetch documents for a specific level
  Future<void> fetchDocumentsForLevel(String matricNumber, String level) async {
    try {
      _setLoading(true);
      _documents =
          await _documentService.fetchDocuments(matricNumber, level: level);
      _setLoading(false);
    } catch (e) {
      _handleError('Error fetching documents for level: $e');
    }
  }

  // Fetch recent documents with pagination support
  Future<void> fetchRecentDocuments({int limit = 10, int offset = 0}) async {
    try {
      _setLoading(true);
      final results = await _documentService.fetchRecentDocuments(
        limit: limit,
        startAfterDocId: offset > 0 ? _lastDocumentId : null,
      );

      if (results.isNotEmpty) {
        _lastDocumentId = results.last.id;

        if (offset == 0) {
          _recentDocuments = results;
        } else {
          _recentDocuments = [..._recentDocuments, ...results];
        }
      }

      // If fewer documents returned than requested, we've reached the end
      if (results.length < limit) {
        _hasMoreSearchResults = false;
      }

      _setLoading(false);
    } catch (e) {
      _handleError('Error fetching recent documents: $e');
    }
  }

  // Fetch total documents count
  Future<void> fetchTotalDocumentsCount() async {
    try {
      _setLoading(true);
      _totalDocumentsCount = await _documentService.fetchTotalDocumentsCount();
      _setLoading(false);
    } catch (e) {
      _handleError('Error fetching total documents count: $e');
    }
  }

  // Search documents with proper server-side filtering and pagination
  Future<void> searchDocuments({
    required Map<String, dynamic> searchParams,
    bool append = false,
  }) async {
    try {
      _setLoading(true);
      final results = await _documentService.searchDocuments(
        query: searchParams['query'] as String?,
        level: searchParams['level'] as String?,
        documentType: searchParams['documentType'] as String?,
        dateRange: searchParams['dateRange'] as String?,
        limit: searchParams['itemsPerPage'] as int? ?? 20,
        startAfterDocId: append ? _lastDocumentId : null,
      );
      if (!append) {
        _searchResults = results; // Always update, even if empty
        _hasMoreSearchResults = true;
        if (results.isNotEmpty) {
          // Add to recently searched, avoiding duplicates
          _recentlySearchedDocuments = [
            ...results,
            ..._recentlySearchedDocuments
                .where((doc) => !results.any((r) => r.id == doc.id)),
          ].take(10).toList(); // Limit to 10 items
        }
      } else if (results.isNotEmpty) {
        _searchResults = [..._searchResults, ...results];
        _recentlySearchedDocuments = [
          ...results,
          ..._recentlySearchedDocuments
              .where((doc) => !results.any((r) => r.id == doc.id)),
        ].take(10).toList();
      }
      if (results.isNotEmpty) {
        _lastDocumentId = results.last.id;
      }
      if (results.length < (searchParams['itemsPerPage'] as int? ?? 20)) {
        _hasMoreSearchResults = false;
      }
      _setLoading(false);
    } catch (e) {
      _searchResults = append ? _searchResults : []; // Reset if not appending
      _handleError('Error searching documents: $e');
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    _lastDocumentId = null;
    _hasMoreSearchResults = true;
    notifyListeners();
  }

  // Save a document
  Future<void> saveDocument(DocumentModel document) async {
    try {
      _setLoading(true);
      final isNewUser = await _documentService.saveDocument(document);
      // Update local state
      _documents = [..._documents, document];
      _totalDocumentsCount++;
      if (isNewUser) {
        _users = [
          ..._users,
          {
            'name': document.userName,
            'matricNumber': document.matricNumber,
          }
        ];
      }
      // Update recent documents if necessary
      if (_recentDocuments.isNotEmpty) {
        _recentDocuments = [document, ..._recentDocuments];
        // Keep the recent documents list at a reasonable size
        if (_recentDocuments.length > 20) {
          _recentDocuments = _recentDocuments.sublist(0, 20);
        }
      }

      _setLoading(false);
    } catch (e) {
      _handleError('Error saving document: $e');
    }
  }

  // Delete a document
  Future<void> deleteDocument(DocumentModel document) async {
    try {
      _setLoading(true);
      await _documentService.deleteDocument(
          document.id, document.matricNumber, document.level);

      // Update local state
      _documents = _documents.where((doc) => doc.id != document.id).toList();
      _recentDocuments =
          _recentDocuments.where((doc) => doc.id != document.id).toList();
      _searchResults =
          _searchResults.where((doc) => doc.id != document.id).toList();
      _totalDocumentsCount--;

      _setLoading(false);
    } catch (e) {
      _handleError('Error deleting document: $e');
    }
  }

  // Update a document
  Future<void> updateDocument(DocumentModel document) async {
    try {
      _setLoading(true);
      await _documentService.updateDocument(document);

      // Update local state
      _documents = _documents
          .map((doc) => doc.id == document.id ? document : doc)
          .toList();

      _recentDocuments = _recentDocuments
          .map((doc) => doc.id == document.id ? document : doc)
          .toList();

      _searchResults = _searchResults
          .map((doc) => doc.id == document.id ? document : doc)
          .toList();

      _setLoading(false);
    } catch (e) {
      _handleError('Error updating document: $e');
    }
  }

  // Fetch a single document by ID
  Future<DocumentModel?> fetchDocumentById(
      String documentId, String matricNumber, String level) async {
    try {
      _setLoading(true);
      final document = await _documentService.fetchDocumentById(
          documentId, matricNumber, level);
      _setLoading(false);
      return document;
    } catch (e) {
      _handleError('Error fetching document: $e');
      return null;
    }
  }

  // Helper function to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Helper function to handle errors
  void _handleError(String errorMessage) {
    _error = errorMessage;
    _isLoading = false;
    notifyListeners();
  }

  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load more search results with pagination
  Future<void> loadMoreSearchResults(Map<String, dynamic> searchParams) async {
    if (_hasMoreSearchResults && !_isLoading) {
      await searchDocuments(searchParams: searchParams, append: true);
    }
  }

  // Clear recently searched documents if needed
  void clearRecentlySearched() {
    _recentlySearchedDocuments = [];
    notifyListeners();
  }
}
