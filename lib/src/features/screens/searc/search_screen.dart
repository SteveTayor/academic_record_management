import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/model/document_model.dart';
import '../../../core/providers/document_provider.dart';
import 'package:provider/provider.dart';

import '../other_screens/dcuments/document_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const SearchScreen({
    super.key,
    required this.selectedMenu,
    required this.onMenuSelected,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedDateRange;
  String? selectedLevel;
  String? selectedDocumentType;
  bool isSearching = false;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  bool _hasMoreItems = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initialize with recent documents
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<DocumentNavigationProvider>(context, listen: false);
      provider.fetchRecentDocuments(limit: _itemsPerPage);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMoreItems && !isSearching) {
        _loadMoreItems();
      }
    }
  }

  void _loadMoreItems() {
    final provider =
        Provider.of<DocumentNavigationProvider>(context, listen: false);
    if (provider.isLoading) return;

    setState(() {
      _currentPage++;
    });

    // Implement pagination based on search context
    if (_searchController.text.isNotEmpty) {
      _performSearch(page: _currentPage, append: true);
    } else {
      // Load more recent documents
      provider.fetchRecentDocuments(
          limit: _itemsPerPage, offset: (_currentPage - 1) * _itemsPerPage);
    }
  }

  Future<void> _performSearch({int page = 1, bool append = false}) async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty &&
        selectedLevel == null &&
        selectedDocumentType == null &&
        selectedDateRange == null) {
      _showErrorSnackBar('Please enter a search term or select filters');
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final provider =
          Provider.of<DocumentNavigationProvider>(context, listen: false);

      // Create search parameters object
      final searchParams = {
        'query': searchText,
        'level': selectedLevel,
        'documentType': selectedDocumentType,
        'dateRange': selectedDateRange,
        'page': page,
        'itemsPerPage': _itemsPerPage,
      };

      // Call provider's search method
      await provider.searchDocuments(
        searchParams: searchParams,
        append: append,
      );

      // Update pagination state
      setState(() {
        _hasMoreItems = provider.hasMoreSearchResults;
      });
    } catch (e) {
      _showErrorSnackBar('Error searching: ${e.toString()}');
    } finally {
      setState(() {
        isSearching = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      selectedDateRange = null;
      selectedLevel = null;
      selectedDocumentType = null;
      _currentPage = 1;
      _hasMoreItems = true;
    });

    final provider =
        Provider.of<DocumentNavigationProvider>(context, listen: false);
    provider.clearSearch();
    // provider.fetchRecentDocuments(limit: _itemsPerPage);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs - selectable
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigate to Documents page
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Documents',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 16),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _clearSearch,
                        child: Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Search documents',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search field and button
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              fillColor: Colors.blueGrey.shade50,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _searchController.text.isNotEmpty
                                        ? Colors.blue.withOpacity(0.3)
                                        : Colors.blueGrey.shade50),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue.shade400, width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              border: InputBorder.none,
                              hintText: 'Search by student name, matric...',
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _clearSearch();
                                      },
                                    )
                                  : null,
                            ),
                            onSubmitted: (_) => _performSearch(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _performSearch(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Filters section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selectedDateRange != null ||
                          selectedLevel != null ||
                          selectedDocumentType != null)
                        TextButton.icon(
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear Filters'),
                          onPressed: () {
                            setState(() {
                              selectedDateRange = null;
                              selectedLevel = null;
                              selectedDocumentType = null;
                            });
                            if (_searchController.text.isNotEmpty) {
                              _performSearch();
                            } else {
                              _clearSearch();
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filter selectors
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Upload Date'),
                            const SizedBox(height: 8),
                            _buildFilterSelector(
                              'Select date range',
                              Icons.calendar_today,
                              selectedDateRange,
                              (value) {
                                setState(() => selectedDateRange = value);
                                _performSearch();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Academic Level'),
                            const SizedBox(height: 8),
                            _buildFilterSelector(
                              'Select level',
                              Icons.school,
                              selectedLevel,
                              (value) {
                                setState(() => selectedLevel = value);
                                _performSearch();
                              },
                              options: [
                                '100 Level',
                                '200 Level',
                                '300 Level',
                                '400 Level',
                                '500 Level'
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Document Type'),
                            const SizedBox(height: 8),
                            _buildFilterSelector(
                              'Select type',
                              Icons.description,
                              selectedDocumentType,
                              (value) {
                                setState(() => selectedDocumentType = value);
                                _performSearch();
                              },
                              options: [
                                'Transcript',
                                'Exam Paper',
                                'Research Paper',
                                'Letter',
                                'Other'
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Search Results
                  // Consumer<DocumentNavigationProvider>(
                  //   builder: (context, provider, child) {
                  //     final List<DocumentModel> results =
                  //         provider.searchResults.isNotEmpty
                  //             ? provider.searchResults
                  //             : provider.recentDocuments;

                  //     final String resultsTitle =
                  //         provider.searchResults.isNotEmpty
                  //             ? 'Search Results'
                  //             : 'Recent Documents';
                  Consumer<DocumentNavigationProvider>(
                    builder: (context, provider, child) {
                      if (provider.error != null) {
                        return Center(
                            child: SelectableText('Error: ${provider.error}'));
                      }
                      // Determine what to display
                      final bool hasSearchCriteria =
                          _searchController.text.isNotEmpty ||
                              selectedLevel != null ||
                              selectedDocumentType != null ||
                              selectedDateRange != null;
                      final List<DocumentModel> results = hasSearchCriteria
                          ? provider.searchResults
                          : provider.recentlySearchedDocuments;
                      final String resultsTitle = hasSearchCriteria
                          ? 'Search Results'
                          : 'Recently Searched Documents';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                resultsTitle,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${results.length} document(s) found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Results table
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: provider.isLoading && results.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: results.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 32,
                                              horizontal: 16,
                                            ),
                                            child: Center(
                                              child: Text(
                                                hasSearchCriteria
                                                    ? 'No documents found. Try a different search.'
                                                    : 'No recently searched documents.',
                                              ),
                                            ),
                                          )
                                        : _buildDocumentsList(
                                            results, provider),
                                  ),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(
      List<DocumentModel> documents, DocumentNavigationProvider provider) {
    print('Debug: Building list with ${documents.length} documents');
    return SizedBox(
      // height: MediaQuery.sizeOf,
      child: Expanded(
        child: ListView.separated(
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: documents.length + (_hasMoreItems ? 1 : 0),
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom while loading more items
            if (index == documents.length) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            }

            final doc = documents[index];
            if (doc.userName.isEmpty) {
              print('Debug: Invalid document at index $index');
              return const ListTile(title: Text('Invalid Document'));
            }
            print('Debug: Rendering document ${doc.userName}');
            return Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(
                  _getDocumentIcon(doc.documentType),
                  color: Colors.blue[800],
                ),
                title: Text(doc.userName ?? 'Unknown'),
                // return ListTile(
                //   leading: Icon(
                //     _getDocumentIcon(doc.documentType),
                //     color: Colors.blue[800],
                //   ),
                //   title: Text(doc.userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.matricNumber),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            doc.documentType,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            doc.level,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(doc.timestamp),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () {
                        _showDocumentPreview(doc);
                      },
                      tooltip: 'View',
                    ),
                    IconButton(
                      icon: const Icon(Icons.download_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Download functionality will be implemented'),
                          ),
                        );
                      },
                      tooltip: 'Download',
                    ),
                  ],
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                visualDensity: VisualDensity.comfortable,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DocumentDetailScreen(document: doc)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDocumentPreview(DocumentModel document) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${document.documentType} - ${document.userName}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Matric Number: ${document.matricNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    'Level: ${document.level}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    'Date: ${_formatDate(document.timestamp)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(document.text),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'close',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text(
                      //         'Download functionality will be implemented'),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSelector(
    String placeholder,
    IconData icon,
    String? selectedValue,
    Function(String) onChanged, {
    List<String>? options,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(
          selectedValue ?? placeholder,
          style: TextStyle(
            color: selectedValue == null ? Colors.grey : Colors.black,
            fontSize: 14,
          ),
        ),
        trailing: selectedValue != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    if (placeholder.contains('level')) {
                      selectedLevel = null;
                    } else if (placeholder.contains('type')) {
                      selectedDocumentType = null;
                    } else if (placeholder.contains('date')) {
                      selectedDateRange = null;
                    }
                  });
                  _performSearch();
                },
              )
            : Icon(icon),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        onTap: () {
          // Show dropdown or dialog to select value
          if (options != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Select $placeholder'),
                content: SizedBox(
                  width: double.minPositive,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(options[index]),
                        onTap: () {
                          onChanged(options[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          } else {
            // For date range, show date picker
            if (placeholder.contains('date')) {
              _showDateRangePicker(onChanged);
            }
          }
        },
      ),
    );
  }

  void _showDateRangePicker(Function(String) onChanged) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[800]!,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final start =
          "${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}";
      final end =
          "${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}";
      onChanged('$start to $end');
    }
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'Transcript':
        return Icons.school;
      case 'Letter':
        return Icons.mail;
      case 'Exam Paper':
        return Icons.assignment; // Icon for Exam Paper
      case 'Research Paper':
        return Icons.article; // Icon for Research Paper
      case 'Other':
        return Icons.card_membership;
      case 'Result':
        return Icons.insert_chart;
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
