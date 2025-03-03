// import 'package:flutter/material.dart';

// import '../model/document_model.dart';
// import '../service/document_service.dart';

// class SearchProvider extends ChangeNotifier {
//   final DocumentService _documentService = DocumentService();

//   // Search state
//   List<DocumentModel> _searchResults = [];
//   bool _isLoading = false;
//   String? _error;
//   String? _query;
//   String? _level;
//   String? _documentType;
//   String? _dateRange;
//   int _itemsPerPage = 20;

//   // Pagination state
//   bool _hasMoreResults = true;
//   String? _lastDocumentId;

//   // Getters
//   List<DocumentModel> get searchResults => _searchResults;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get hasMoreResults => _hasMoreResults;
//   String? get query => _query;
//   String? get level => _level;
//   String? get documentType => _documentType;
//   String? get dateRange => _dateRange;

//   // Check if search has any filters active
//   bool get hasFilters =>
//       (_query != null && _query!.isNotEmpty) ||
//       (_level != null && _level!.isNotEmpty) ||
//       (_documentType != null && _documentType!.isNotEmpty) ||
//       (_dateRange != null && _dateRange!.isNotEmpty);

//   // Set search parameters
//   void setSearchParameters({
//     String? query,
//     String? level,
//     String? documentType,
//     String? dateRange,
//     int? itemsPerPage,
//   }) {
//     bool shouldNotify = false;

//     if (query != null && query != _query) {
//       _query = query;
//       shouldNotify = true;
//     }

//     if (level != null && level != _level) {
//       _level = level;
//       shouldNotify = true;
//     }

//     if (documentType != null && documentType != _documentType) {
//       _documentType = documentType;
//       shouldNotify = true;
//     }

//     if (dateRange != null && dateRange != _dateRange) {
//       _dateRange = dateRange;
//       shouldNotify = true;
//     }

//     if (itemsPerPage != null && itemsPerPage != _itemsPerPage) {
//       _itemsPerPage = itemsPerPage;
//       shouldNotify = true;
//     }

//     if (shouldNotify) {
//       notifyListeners();
//     }
//   }

//   // Clear search parameters
//   void clearSearchParameters() {
//     _query = null;
//     _level = null;
//     _documentType = null;
//     _dateRange = null;
//     notifyListeners();
//   }

//   // Execute search with current parameters
//   Future<void> search({bool append = false}) async {
//     if (!append) {
//       _setLoading(true);
//     }

//     try {
//       final results = await _documentService.searchDocuments(
//         query: _query,
//         level: _level,
//         documentType: _documentType,
//         dateRange: _dateRange,
//         limit: _itemsPerPage,
//         startAfterDocId: append ? _lastDocumentId : null,
//       );

//       if (results.isNotEmpty) {
//         _lastDocumentId = results.last.id;

//         if (append) {
//           _searchResults = [..._searchResults, ...results];
//         } else {
//           _searchResults = results;
//           _hasMoreResults = true; // Reset pagination for new search
//         }
//       } else if (!append) {
//         // Empty results for a new search
//         _searchResults = [];
//       }

//       // If fewer documents returned than requested, we've reached the end
//       if (results.length < _itemsPerPage) {
//         _hasMoreResults = false;
//       }

//       _setLoading(false);
//     } catch (e) {
//       _handleError('Error searching documents: $e');
//     }
//   }

//   // Load more results (pagination)
//   Future<void> loadMore() async {
//     if (_hasMoreResults && !_isLoading) {
//       await search(append: true);
//     }
//   }

//   // Clear search results
//   void clearResults() {
//     _searchResults = [];
//     _lastDocumentId = null;
//     _hasMoreResults = true;
//     notifyListeners();
//   }

//   // Helper function to set loading state
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   // Helper function to handle errors
//   void _handleError(String errorMessage) {
//     _error = errorMessage;
//     _isLoading = false;
//     notifyListeners();
//   }

//   // Clear any error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }
