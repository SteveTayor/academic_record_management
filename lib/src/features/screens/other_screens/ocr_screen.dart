import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

// If you’re using ML Kit on mobile, import google_mlkit_text_recognition
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// If you have a PDF approach on mobile, import your pdf libraries
// import 'package:pdfx/pdfx.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:ui' as ui;
// import 'dart:io';

// For Tesseract.js on web, import dart:js/html
// import 'dart:html' as html; // only works on web

import '../../../core/providers/app_provider.dart';
import '../../../core/model/document_model.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/sidebar.dart';

class OcrUploadScreen extends StatefulWidget {
  const OcrUploadScreen({super.key});

  @override
  State<OcrUploadScreen> createState() => _OcrUploadScreenState();
}

class _OcrUploadScreenState extends State<OcrUploadScreen> {
  // ----------------------------------------
  // 1) OCR-Upload related fields
  // ----------------------------------------
  bool _isProcessing = false;
  bool _isPreviewVisible =
      false; // Controls whether we show the preview or the upload UI
  String _extractedText = '';

  // ----------------------------------------
  // 2) "Preview" / Document form fields
  // ----------------------------------------
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _matricNumberController = TextEditingController();
  final DocumentService _documentService = DocumentService();

  String _selectedLevel = '300 Level';
  String _selectedDocType = 'Other';
  bool _isSaving = false;

  final List<String> _docTypes = [
    'Transcript',
    'Exam Paper',
    'Research Paper',
    'Letter',
    'Other',
  ];

  @override
  void dispose() {
    _userNameController.dispose();
    _matricNumberController.dispose();
    super.dispose();
  }

  // ----------------------------------------
  // 3) Build method: sidebar + conditional UI
  // ----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            selectedMenu: 'Documents',
            onMenuSelected: (String menu) {
              // TODO: Handle navigation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Navigate to $menu')),
              );
            },
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              // Show upload UI OR preview UI
              child: _isPreviewVisible
                  ? _buildPreviewUI(context)
                  : _buildUploadUI(context),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------
  // 4) Upload Section (shown initially)
  // ----------------------------------------
  Widget _buildUploadUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents > OCR Upload',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Icon(Icons.file_upload, color: Colors.blue),
              const SizedBox(height: 8),
              const Text(
                'Upload File',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select a document to extract text using OCR.\nSupported formats: PNG, JPG. (PDF not supported on web)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickAndProcessFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Choose File'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Example: pick file and do OCR
  Future<void> _pickAndProcessFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) {
      _showErrorSnackbar('No file selected.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) throw Exception('File bytes not available.');

      // ----------------------------------
      // Do your OCR logic here...
      // For example, call a function:
      // final recognizedText = await _performOcr(bytes, file.extension);
      // We'll just simulate:
      final recognizedText = 'Sample recognized text from ${file.name}';

      // Save recognized text to state
      setState(() {
        _extractedText = recognizedText;
        _isPreviewVisible = true; // Show preview
      });

      // Also update AppState if needed
      final appState = Provider.of<AppState>(context, listen: false);
      appState.setExtractedText(recognizedText);
      appState.setDocumentType(_selectedDocType);
    } catch (e) {
      _showErrorSnackbar('Error processing file: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ----------------------------------------
  // 5) Preview UI (shown after OCR completes)
  // ----------------------------------------
  Widget _buildPreviewUI(BuildContext context) {
    // If you want to change breadcrumbs once in preview:
    const breadcrumbs = 'Documents > OCR Upload > Preview';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(breadcrumbs,
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 20),
        _buildDocumentPreviewSection(),
        const SizedBox(height: 24),
        _buildStudentDetailsForm(),
        const Spacer(),
        // _buildAdminFooter(),
      ],
    );
  }

  // The same logic from your old DocumentPreviewScreen:
  Widget _buildDocumentPreviewSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.article, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Text(
                  'Document Preview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Text(
              'Extracted Text',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                // If you need "structured view," see below:
                child: _buildStructuredView(_selectedDocType, _extractedText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Example structured view logic
  Widget _buildStructuredView(String documentType, String text) {
    final appState = Provider.of<AppState>(context, listen: false);

    if (documentType == 'Transcript' && appState.currentTranscript != null) {
      final transcript = appState.currentTranscript!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student: ${transcript.student.name}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('Matric Number: ${transcript.student.matricNumber}'),
          Text('Cumulative GPA: ${transcript.cumulativeGpa}'),
          const Text('Courses:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...transcript.student.courses.map((course) => Text(
                '- ${course.courseCode} (${course.description}): ${course.remarks} (${course.marksPercentage}%)',
              )),
        ],
      );
    } else if (documentType == 'Letter' &&
        appState.currentDocument?.structuredData != null) {
      final data = appState.currentDocument!.structuredData!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From: ${data['from'] ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('To: ${data['to'] ?? 'Unknown'}'),
          Text('Date: ${data['date'] ?? 'Unknown'}'),
          Text('Body: ${data['body'] ?? text}'),
        ],
      );
    }
    // Fallback
    return Text(text);
  }

  // ----------------------------------------
  // 6) Form: Student Details
  // ----------------------------------------
  Widget _buildStudentDetailsForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
              ),
              const Divider(height: 30),
              _buildFormField('Student Name', 'Enter student\'s full name',
                  _userNameController),
              const SizedBox(height: 16),
              _buildFormField('Matric Number', 'Enter matric number',
                  _matricNumberController),
              const SizedBox(height: 24),
              _buildLevelSelector(),
              const SizedBox(height: 24),
              _buildDocTypeSelector(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
      String label, String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: label.contains('Name')
            ? const Icon(Icons.search)
            : const Icon(Icons.camera_alt),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Academic Level', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: List.generate(
            4,
            (i) => _selectedLevel == '${(i + 1) * 100} Level',
          ),
          onPressed: (index) {
            setState(() {
              _selectedLevel = '${(index + 1) * 100} Level';
            });
          },
          color: Colors.grey,
          selectedColor: Colors.white,
          fillColor: Colors.purple,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          children: const [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('100 Level')),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('200 Level')),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('300 Level')),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('400 Level')),
          ],
        ),
      ],
    );
  }

  Widget _buildDocTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Document Type', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _docTypes.length,
          itemBuilder: (context, index) {
            final docType = _docTypes[index];
            final isSelected = _selectedDocType == docType;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? Colors.purple[700] : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black,
              ),
              onPressed: () {
                setState(() => _selectedDocType = docType);
                Provider.of<AppState>(context, listen: false)
                    .setDocumentType(docType);
              },
              child: Text(docType),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[600]!),
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveDocument,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[700],
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Save Document'),
        ),
      ],
    );
  }

  Widget _buildAdminFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin User',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'System Administrator',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------
  // 7) Saving Document
  // ----------------------------------------
  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final document = DocumentModel(
        id: '',
        userName: _userNameController.text,
        matricNumber: _matricNumberController.text,
        level: _selectedLevel.replaceAll(' Level', ''), // "300 Level" -> "300"
        text: _extractedText,
        documentType: _selectedDocType,
        fileUrl: '',
        timestamp: DateTime.now(),
      );

      // Save to Firestore
      await _documentService.saveDocument(document);

      // Update AppState
      Provider.of<AppState>(context, listen: false)
          .setCurrentDocument(document);

      // Close or navigate away
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
