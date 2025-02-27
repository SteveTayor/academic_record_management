import 'package:flutter/material.dart';
import '../../../core/model/document_model.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/sidebar.dart';

class SearchScreen extends StatefulWidget {
  final DocumentService documentService;
  final String selectedMenu;
  final Function(String) onMenuSelected;

  const SearchScreen({
    Key? key,
    required this.documentService,
    required this.selectedMenu,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedDateRange;
  String? selectedLevel;
  String? selectedDocumentType;
  List<DocumentModel> searchResults = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch all documents or latest documents as initial data
      final users = await widget.documentService.fetchAllUsers();
      if (users.isNotEmpty) {
        final matricNumber = users.first['matricNumber'] ?? '';
        if (matricNumber.isNotEmpty) {
          final docs =
              await widget.documentService.fetchDocumentsByUser(matricNumber);
          setState(() {
            searchResults = docs;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading documents: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _performSearch() async {
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) {
      _showErrorSnackBar('Please enter a search term');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Check if search text is a matric number
      if (searchText.contains('/')) {
        final docs =
            await widget.documentService.fetchDocumentsByUser(searchText);
        setState(() {
          searchResults = docs;
        });
      } else {
        // Search by name (we'll need to fetch all users then filter)
        final users = await widget.documentService.fetchAllUsers();
        final matchedUsers = users
            .where((user) =>
                user['name']
                    ?.toLowerCase()
                    .contains(searchText.toLowerCase()) ??
                false)
            .toList();

        List<DocumentModel> allDocs = [];
        for (var user in matchedUsers) {
          final matricNumber = user['matricNumber'] ?? '';
          if (matricNumber.isNotEmpty) {
            final docs =
                await widget.documentService.fetchDocumentsByUser(matricNumber);
            allDocs.addAll(docs);
          }
        }

        setState(() {
          searchResults = allDocs;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error searching: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      // Filter the results based on selected filters
      if (selectedLevel != null || selectedDocumentType != null) {
        searchResults = searchResults.where((doc) {
          bool levelMatch = selectedLevel == null || doc.level == selectedLevel;
          bool typeMatch = selectedDocumentType == null ||
              doc.documentType == selectedDocumentType;
          return levelMatch && typeMatch;
        }).toList();
      }
    });
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
          // Using your existing Sidebar component
          // Sidebar(
          //   selectedMenu: widget.selectedMenu,
          //   onMenuSelected: widget.onMenuSelected,
          // ),

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
                        onTap: () {
                          // Refresh Search page
                          _fetchInitialData();
                        },
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
                                  EdgeInsets.symmetric(horizontal: 16),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onSubmitted: (_) => _performSearch(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Advanced Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Filters section
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
                                _applyFilters();
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
                                _applyFilters();
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
                                _applyFilters();
                              },
                              options: [
                                'Transcript',
                                'Letter',
                                'Result',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${searchResults.length} document(s) found',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Results table
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: searchResults.isEmpty
                                ? const Center(
                                    child: Text(
                                        'No documents found. Try a different search.'),
                                  )
                                : ListView.separated(
                                    itemCount: searchResults.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final doc = searchResults[index];
                                      return ListTile(
                                        leading: Icon(
                                          _getDocumentIcon(doc.documentType),
                                          color: Colors.blue[800],
                                        ),
                                        title: Text(doc.userName),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(doc.matricNumber),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
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
                                              icon: const Icon(
                                                  Icons.visibility_outlined),
                                              onPressed: () {
                                                // View document
                                                _showDocumentPreview(doc);
                                              },
                                              tooltip: 'View',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.download_outlined),
                                              onPressed: () {
                                                // Download document
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
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
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                        visualDensity:
                                            VisualDensity.comfortable,
                                        onTap: () => _showDocumentPreview(doc),
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download'),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Download functionality will be implemented'),
                        ),
                      );
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
        trailing: Icon(icon),
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
            } else {
              // Default behavior - set a sample value
              onChanged('Sample ${placeholder.split(' ').last}');
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
