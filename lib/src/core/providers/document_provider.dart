import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import '../model/document_model.dart';
import '../service/document_service.dart';
import 'error_state.dart';
import 'loading_State.dart';

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

  DocumentModel? _lastDocument;
  bool _hasMoreDocuments = true;
  bool get hasMoreDocuments => _hasMoreDocuments;

  // Pagination for search results
  bool _hasMoreSearchResults = true;
  String? _lastDocumentId;

  // Logger name for easier filtering in console
  static const String _logName = 'DocumentNavigationProvider';

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
  final LoadingState loadingState = LoadingState();
  final ErrorState errorState = ErrorState();

  void _setLoading(bool loading, [String? message]) {
    final previousState = _isLoading;
    _isLoading = loading;

    if (loading && message != null) {
      loadingState.startLoading(message);
    } else if (!loading) {
      loadingState.stopLoading();
    }

    if (previousState != loading) {
      _logInfo('Loading state changed: $loading');
      notifyListeners();
    }
  }

  void _handleError(String errorMessage, [StackTrace? stackTrace]) {
    _error = errorMessage;
    errorState.setError(errorMessage,
        actionLabel: 'Retry', onAction: () => clearError());
    _logError('Error occurred', errorMessage, stackTrace);
    _isLoading = false;
    notifyListeners();
  }

  // Update your clearError method
  void clearError() {
    _logInfo('Clearing error: $_error');
    _error = null;
    errorState.clearError();
    notifyListeners();
  }

  // Fetch all users from Firestore
  Future<void> fetchAllUsers() async {
    _logInfo('Fetching all users...');
    try {
      _setLoading(true, 'Loading users...');
      _users = await _documentService.fetchAllUsers();
      _logSuccess('Successfully fetched ${_users.length} users');
      _setLoading(false);
    } catch (e, stackTrace) {
      _handleError('Error fetching users: $e', stackTrace);
    }
  }

  // Fetch levels for a specific user
  Future<List<String>> fetchLevelsForUser(String matricNumber) async {
    _logInfo('Fetching levels for user: $matricNumber');
    try {
      // Check cache first
      if (_levelsCache.containsKey(matricNumber)) {
        _logInfo('Using cached levels for user: $matricNumber');
        return _levelsCache[matricNumber]!;
      }

      _setLoading(true);
      final levels = await _documentService.fetchLevelsForUser(matricNumber);
      _levelsCache[matricNumber] = levels;
      _logSuccess(
          'Successfully fetched ${levels.length} levels for user: $matricNumber');
      _setLoading(false);
      return levels;
    } catch (e, stackTrace) {
      _handleError(
          'Error fetching levels for user $matricNumber: $e', stackTrace);
      return [];
    }
  }

  // Fetch documents for a specific user
  Future<void> fetchDocumentsByUser(String matricNumber) async {
    _logInfo('Fetching documents for user: $matricNumber');
    try {
      _setLoading(true);
      _documents = await _documentService.fetchDocumentsByUser(matricNumber);
      _logSuccess(
          'Successfully fetched ${_documents.length} documents for user: $matricNumber');
      _setLoading(false);
    } catch (e, stackTrace) {
      _handleError(
          'Error fetching documents for user $matricNumber: $e', stackTrace);
    }
  }

  // Fetch documents for a specific level
  Future<void> fetchDocumentsForLevel(String matricNumber, String level) async {
    _logInfo('Fetching documents for user: $matricNumber, level: $level');
    try {
      _setLoading(true);
      _documents =
          await _documentService.fetchDocuments(matricNumber, level: level);
      _logSuccess(
          'Successfully fetched ${_documents.length} documents for user: $matricNumber, level: $level');
      _setLoading(false);
    } catch (e, stackTrace) {
      _handleError(
          'Error fetching documents for user $matricNumber, level $level: $e',
          stackTrace);
    }
  }

  // Fetch recent documents with pagination support
  Future<void> fetchRecentDocuments({int limit = 10, int offset = 0}) async {
    _logInfo('Fetching recent documents with limit: $limit, offset: $offset');
    try {
      _setLoading(true);
      final startTime = DateTime.now();
      final results = await _documentService.fetchRecentDocuments(
        limit: limit,
        startAfterDocId: offset > 0 ? _lastDocumentId : null,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logPerformance(
          'Recent documents fetch took ${duration.inMilliseconds}ms');

      if (results.isNotEmpty) {
        _lastDocumentId = results.last.id;
        _logInfo('Last document ID updated to: $_lastDocumentId');

        if (offset == 0) {
          _recentDocuments = results;
          _logInfo('Reset recent documents with ${results.length} new items');
        } else {
          _recentDocuments = [..._recentDocuments, ...results];
          _logInfo(
              'Appended ${results.length} items to recent documents. Total: ${_recentDocuments.length}');
        }
      } else {
        _logInfo('No recent documents found');
      }

      // If fewer documents returned than requested, we've reached the end
      if (results.length < limit) {
        _hasMoreSearchResults = false;
        _logInfo('Reached end of recent documents');
      }

      _setLoading(false);
    } catch (e, stackTrace) {
      _handleError('Error fetching recent documents: $e', stackTrace);
    }
  }

  // Fetch more documents for lazy loading
  Future<void> fetchMoreDocuments({
    required DocumentModel startAfter,
    int limit = 10,
  }) async {
    if (!_hasMoreDocuments || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final moreDocuments = await _documentService.fetchMoreDocuments(
        startAfter: startAfter,
        limit: limit,
      );

      if (moreDocuments.isEmpty) {
        _hasMoreDocuments = false;
      } else {
        _recentDocuments.addAll(moreDocuments);
        _lastDocument = moreDocuments.last;
        _hasMoreDocuments = moreDocuments.length >= limit;
      }
    } catch (e) {
      _error = e.toString();
      // Don't update the UI with an error when fetching more - just stop
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch total documents count
  Future<void> fetchTotalDocumentsCount() async {
    _logInfo('Fetching total documents count');
    try {
      _setLoading(true);
      final startTime = DateTime.now();
      _totalDocumentsCount = await _documentService.fetchTotalDocumentsCount();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logPerformance(
          'Total documents count fetch took ${duration.inMilliseconds}ms');
      _logSuccess('Total documents count: $_totalDocumentsCount');
      _setLoading(false);
    } catch (e, stackTrace) {
      _handleError('Error fetching total documents count: $e', stackTrace);
    }
  }

  // Search documents with proper server-side filtering and pagination
  Future<void> searchDocuments({
    required Map<String, dynamic> searchParams,
    bool append = false,
  }) async {
    final query = searchParams['query'] as String?;
    final level = searchParams['level'] as String?;
    final documentType = searchParams['documentType'] as String?;
    final dateRange = searchParams['dateRange'] as String?;
    final limit = searchParams['itemsPerPage'] as int? ?? 20;

    _logInfo('Searching documents with params: \n'
        'query: $query, level: $level, type: $documentType, \n'
        'dateRange: $dateRange, limit: $limit, append: $append, \n'
        'startAfter: ${append ? _lastDocumentId : "none"}');

    try {
      _setLoading(true);
      final startTime = DateTime.now();
      final results = await _documentService.searchDocuments(
        query: query,
        level: level,
        documentType: documentType,
        dateRange: dateRange,
        limit: limit,
        startAfterDocId: append ? _lastDocumentId : null,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logPerformance(
          'Document search took ${duration.inMilliseconds}ms, found ${results.length} results');

      if (!append) {
        _searchResults = results; // Always update, even if empty
        _hasMoreSearchResults = true;
        _logInfo('Reset search results with ${results.length} documents');

        if (results.isNotEmpty) {
          // Add to recently searched, avoiding duplicates
          final prevRecentCount = _recentlySearchedDocuments.length;
          _recentlySearchedDocuments = [
            ...results,
            ..._recentlySearchedDocuments
                .where((doc) => !results.any((r) => r.id == doc.id)),
          ].take(10).toList(); // Limit to 10 items
          _logInfo(
              'Updated recently searched documents: ${_recentlySearchedDocuments.length} items (was $prevRecentCount)');
        }
      } else if (results.isNotEmpty) {
        final prevCount = _searchResults.length;
        _searchResults = [..._searchResults, ...results];
        _logInfo(
            'Appended ${results.length} documents to search results. Total: ${_searchResults.length} (was $prevCount)');

        final prevRecentCount = _recentlySearchedDocuments.length;
        _recentlySearchedDocuments = [
          ...results,
          ..._recentlySearchedDocuments
              .where((doc) => !results.any((r) => r.id == doc.id)),
        ].take(10).toList();
        _logInfo(
            'Updated recently searched documents: ${_recentlySearchedDocuments.length} items (was $prevRecentCount)');
      } else {
        _logInfo('No documents found for the search query');
      }

      if (results.isNotEmpty) {
        _lastDocumentId = results.last.id;
        _logInfo('Updated last document ID to: ${results.last.id}');
      }

      if (results.length < limit) {
        _hasMoreSearchResults = false;
        _logInfo(
            'Reached end of search results (received ${results.length} < requested $limit)');
      }

      _setLoading(false);
    } catch (e, stackTrace) {
      _searchResults = append ? _searchResults : []; // Reset if not appending
      _logError('Search failed', e, stackTrace);
      _handleError('Error searching documents: $e', stackTrace);
    }
  }

  // Clear search results
  void clearSearch() {
    _logInfo('Clearing search results');
    _searchResults = [];
    _lastDocumentId = null;
    _hasMoreSearchResults = true;
    notifyListeners();
  }

  // Save a document
  Future<void> saveDocument(DocumentModel document) async {
    _logInfo('Saving document: ${document.documentType} (ID: ${document.id})');
    try {
      _setLoading(true);
      final startTime = DateTime.now();
      final isNewUser = await _documentService.saveDocument(document);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logPerformance('Document save took ${duration.inMilliseconds}ms');

      // Update local state
      _documents = [..._documents, document];
      _totalDocumentsCount++;
      _logSuccess(
          'Document saved successfully. New total count: $_totalDocumentsCount');

      if (isNewUser) {
        _users = [
          ..._users,
          {
            'name': document.userName,
            'matricNumber': document.matricNumber,
          }
        ];
        _logInfo(
            'Added new user: ${document.userName} (${document.matricNumber})');
      }

      // Update recent documents if necessary
      if (_recentDocuments.isNotEmpty) {
        _recentDocuments = [document, ..._recentDocuments];
        // Keep the recent documents list at a reasonable size
        if (_recentDocuments.length > 20) {
          _recentDocuments = _recentDocuments.sublist(0, 20);
          _logInfo('Trimmed recent documents list to 20 items');
        }
        _logInfo('Added document to recent documents list');
      }

      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      _handleError('Error saving document: $e', stackTrace);
      notifyListeners();
    }
  }

  // Delete a document
  Future<void> deleteDocument(DocumentModel document) async {
    _logInfo(
        'Deleting document: ${document.documentType} (ID: ${document.id})');
    try {
      _setLoading(true);
      final startTime = DateTime.now();
      await _documentService.deleteDocument(
          document.id, document.matricNumber, document.level);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logPerformance('Document deletion took ${duration.inMilliseconds}ms');

      // Update local state
      final prevDocsCount = _documents.length;
      _documents = _documents.where((doc) => doc.id != document.id).toList();
      _logInfo(
          'Removed document from documents list. Count: ${_documents.length} (was $prevDocsCount)');

      final prevRecentCount = _recentDocuments.length;
      _recentDocuments =
          _recentDocuments.where((doc) => doc.id != document.id).toList();
      _logInfo(
          'Removed document from recent documents list. Count: ${_recentDocuments.length} (was $prevRecentCount)');

      final prevSearchCount = _searchResults.length;
      _searchResults =
          _searchResults.where((doc) => doc.id != document.id).toList();
      _logInfo(
          'Removed document from search results list. Count: ${_searchResults.length} (was $prevSearchCount)');

      _totalDocumentsCount--;
      _logSuccess(
          'Document deleted successfully. New total count: $_totalDocumentsCount');

      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      _logError('Deleting failed', e, stackTrace);
      _handleError('Error deleting document: $e', stackTrace);
      notifyListeners();
    }
  }

  // Update a document
  Future<void> updateDocument(DocumentModel document) async {
    _logInfo(
        'Updating document: ${document.documentType} (ID: ${document.id})');
    try {
      _setLoading(true);
      final startTime = DateTime.now();
      await _documentService.updateDocument(document);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logPerformance('Document update took ${duration.inMilliseconds}ms');

      // Update local state
      _documents = _documents
          .map((doc) => doc.id == document.id ? document : doc)
          .toList();
      _logInfo('Updated document in documents list');

      _recentDocuments = _recentDocuments
          .map((doc) => doc.id == document.id ? document : doc)
          .toList();
      _logInfo('Updated document in recent documents list');

      _searchResults = _searchResults
          .map((doc) => doc.id == document.id ? document : doc)
          .toList();
      _logInfo('Updated document in search results list');

      _logSuccess('Document updated successfully: ${document.id}');
      notifyListeners();
      _setLoading(false);
    } catch (e, stackTrace) {
      _handleError('Error updating document: $e', stackTrace);
      notifyListeners();
    }
  }

  // Fetch a single document by ID
  Future<DocumentModel?> fetchDocumentById(
      String documentId, String matricNumber, String level) async {
    _logInfo(
        'Fetching document by ID: $documentId (Matric: $matricNumber, Level: $level)');
    try {
      _setLoading(true);
      final startTime = DateTime.now();
      final document = await _documentService.fetchDocumentById(
          documentId, matricNumber, level);
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      _logPerformance('Document fetch took ${duration.inMilliseconds}ms');

      if (document != null) {
        _logSuccess('Successfully fetched document: ${document.documentType}');
      } else {
        _logWarning('Document not found: $documentId');
      }

      _setLoading(false);
      return document;
    } catch (e, stackTrace) {
      _handleError('Error fetching document $documentId: $e', stackTrace);
      return null;
    }
  }

  // Load more search results with pagination
  Future<void> loadMoreSearchResults(Map<String, dynamic> searchParams) async {
    _logInfo(
        'Loading more search results. Has more: $_hasMoreSearchResults, Is loading: $_isLoading');
    if (_hasMoreSearchResults && !_isLoading) {
      await searchDocuments(searchParams: searchParams, append: true);
    } else {
      _logInfo(
          'Skipped loading more results - either at end or already loading');
    }
  }

  // Clear recently searched documents if needed
  void clearRecentlySearched() {
    _logInfo('Clearing recently searched documents');
    _recentlySearchedDocuments = [];
    notifyListeners();
  }

  // Helper function to set loading state
  // void _setLoading(bool loading) {
  //   final previousState = _isLoading;
  //   _isLoading = loading;
  //   if (previousState != loading) {
  //     _logInfo('Loading state changed: $loading');
  //     notifyListeners();
  //   }
  // }

  // Helper function to handle errors
  // void _handleError(String errorMessage, [StackTrace? stackTrace]) {
  //   _error = errorMessage;
  //   _logError('Error occurred', errorMessage, stackTrace);
  //   _isLoading = false;
  //   notifyListeners();
  // }

  // // Clear any error
  // void clearError() {
  //   _logInfo('Clearing error: $_error');
  //   _error = null;
  //   notifyListeners();
  // }

  // Log methods for different types of logs
  void _logInfo(String message) {
    developer.log(message, name: '$_logName:INFO');
    // For web console with styling
    print('📘 $_logName: $message');
  }

  void _logSuccess(String message) {
    developer.log(message, name: '$_logName:SUCCESS');
    // For web console with styling
    print('✅ $_logName: $message');
  }

  void _logWarning(String message) {
    developer.log(message, name: '$_logName:WARNING');
    // For web console with styling
    print('⚠️ $_logName: $message');
  }

  void _logError(String context, Object error, [StackTrace? stackTrace]) {
    developer.log('$context: $error',
        name: '$_logName:ERROR', error: error, stackTrace: stackTrace);
    // For web console with styling
    print('❌ $_logName ERROR - $context:');
    print('🔍 Details: $error');
    if (stackTrace != null) {
      print('📜 Stack trace:');
      print(stackTrace);
    }
  }

  void _logPerformance(String message) {
    developer.log(message, name: '$_logName:PERFORMANCE');
    // For web console with styling
    print('⏱️ $_logName: $message');
  }
}
