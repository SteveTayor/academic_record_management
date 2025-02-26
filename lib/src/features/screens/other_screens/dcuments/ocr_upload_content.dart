import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/model/document_model.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/service/document_service.dart';
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'dart:typed_data';

class OcrUploadContent extends StatefulWidget {
  const OcrUploadContent({Key? key}) : super(key: key);

  @override
  _OcrUploadContentState createState() => _OcrUploadContentState();
}

class _OcrUploadContentState extends State<OcrUploadContent> {
  bool _isProcessing = false;
  bool _isPreviewVisible = false;
  String _extractedText = '';
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _matricNumberController = TextEditingController();
  final _extractedTextController = TextEditingController();
  final DocumentService _documentService = DocumentService();
  String _selectedLevel = '300 Level';
  String _selectedDocType = 'Other';
  bool _isSaving = false;
  final List<String> _docTypes = [
    'Transcript',
    'Exam Paper',
    'Research Paper',
    'Letter',
    'Other'
  ];

  @override
  void dispose() {
    _userNameController.dispose();
    _matricNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(
                        context, (route) => route.settings.name == 'overview');
                  },
                  child: const Text('Documents'),
                ),
                const Text(' > OCR Upload'),
              ],
            ),
            const SizedBox(height: 16),
            _isPreviewVisible ? _buildPreviewUI() : _buildUploadUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
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
                'Select a document to extract text using OCR.\nSupported formats: PNG, JPG.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isProcessing ? null : _pickAndProcessFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
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

  Future<void> _pickAndProcessFile() async {
    final pickResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (pickResult == null || pickResult.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final file = pickResult.files.single;
      final bytes = file.bytes;
      if (bytes == null) throw Exception('File bytes not available.');

      // Check if Tesseract is loaded
      final tesseractAvailable = js.context.hasProperty('Tesseract');
      if (!tesseractAvailable) {
        final script =
            js.context['document'].callMethod('createElement', ['script']);
        js_util.setProperty(script, 'src',
            'https://cdn.jsdelivr.net/npm/tesseract.js@4/dist/tesseract.min.js');
        js_util.setProperty(script, 'async', true);
        js.context['document']
            .callMethod('head', []).callMethod('appendChild', [script]);

        // Wait for script to load
        await Future.delayed(const Duration(seconds: 2));
      }

      // **CHANGED**: Pass the ArrayBuffer instead of `[bytes]`
      final buffer = bytes.buffer;
      final typedArray = js.JsObject(js.context['Uint8Array'], [buffer]);

      // **CHANGED**: Use a single typed array in an array for Blob parts
      final blobParts = js.JsArray();
      blobParts.add(typedArray);

      final blobOptions =
          js.JsObject.jsify({'type': 'image/${file.extension}'});
      final blob = js.JsObject(js.context['Blob'], [blobParts, blobOptions]);

      final url = js.context['URL'].callMethod('createObjectURL', [blob]);

      final worker = js.context['Tesseract'].callMethod('createWorker', []);
      await js_util.promiseToFuture(worker.callMethod('load', []));
      await js_util.promiseToFuture(worker.callMethod('loadLanguage', ['eng']));
      await js_util.promiseToFuture(worker.callMethod('initialize', ['eng']));

      final result =
          await js_util.promiseToFuture(worker.callMethod('recognize', [url]));
      final recognizedText = js_util.getProperty(result, 'data')['text'];

      await js_util.promiseToFuture(worker.callMethod('terminate', []));
      js.context['URL'].callMethod('revokeObjectURL', [url]);

      setState(() {
        _extractedText = recognizedText;
        _extractedTextController.text = recognizedText;
        _isPreviewVisible = true;
      });

      Provider.of<AppState>(context, listen: false)
        ..setExtractedText(recognizedText)
        ..setDocumentType(_selectedDocType);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildPreviewUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildDocumentPreviewSection(),
          const SizedBox(height: 24),
          _buildStudentDetailsForm(),
          const SizedBox(height: 24),
          _buildAdminFooter(),
        ],
      ),
    );
  }

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
                      color: Colors.purple[800]),
                ),
              ],
            ),
            const Divider(height: 30),
            Text(
              'Extracted Text',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                controller: _extractedTextController,
                maxLines: null, // Allows multiple lines
                minLines: 10, // Ensures sufficient space
                decoration: InputDecoration(
                  fillColor: Colors.blueGrey.shade50,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey.shade50),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  border: InputBorder.none,
                ),
              ),
              // SingleChildScrollView(
              //   child: Text(_extractedText),
              // ),
            ),
          ],
        ),
      ),
    );
  }

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
                    color: Colors.purple[800]),
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
              4, (i) => _selectedLevel == '${(i + 1) * 100} Level'),
          onPressed: (index) =>
              setState(() => _selectedLevel = '${(index + 1) * 100} Level'),
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
          color: Colors.grey,
          selectedColor: Colors.white,
          fillColor: Colors.purple,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
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
        Wrap(
          spacing: 8, // Horizontal spacing between chips
          runSpacing: 8, // Vertical spacing between lines
          children: _docTypes.map((docType) {
            return _DocTypeChip(
              label: docType,
              isSelected: _selectedDocType == docType,
              onSelected: () {
                setState(() {
                  _selectedDocType = docType;
                });
                Provider.of<AppState>(context, listen: false)
                    .setDocumentType(docType);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget _buildDocTypeSelector() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text('Document Type', style: TextStyle(fontSize: 16)),
  //       const SizedBox(height: 8),
  //       GridView.builder(
  //         shrinkWrap: true,
  //         physics: const NeverScrollableScrollPhysics(),
  //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 3,
  //           childAspectRatio: 3,
  //           mainAxisSpacing: 8,
  //           crossAxisSpacing: 8,
  //         ),
  //         itemCount: _docTypes.length,
  //         itemBuilder: (context, index) {
  //           final docType = _docTypes[index];
  //           final isSelected = _selectedDocType == docType;
  //           return ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor:
  //                   isSelected ? Colors.blue[800] : Colors.grey[200],
  //               foregroundColor: isSelected ? Colors.white : Colors.black,
  //             ),
  //             onPressed: () {
  //               setState(() => _selectedDocType = docType);
  //               Provider.of<AppState>(context, listen: false)
  //                   .setDocumentType(docType);
  //             },
  //             child: Text(docType),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

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
          Text('System Administrator',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Future<void> _saveDocument() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final document = DocumentModel(
        id: '',
        userName: _userNameController.text, // Assuming you have this
        matricNumber: _matricNumberController.text, // Assuming you have this
        level: _selectedLevel.replaceAll(' Level', ''), // Adjust as needed
        text: _extractedTextController.text, // Use the edited text
        documentType: _selectedDocType,
        fileUrl: '',
        timestamp: DateTime.now(),
      );
      // Save the document (e.g., via a provider or service)
      // Provider.of<AppState>(context, listen: false).setCurrentDocument(document);
      // final document = DocumentModel(
      //   id: '',
      //   userName: _userNameController.text,
      //   matricNumber: _matricNumberController.text,
      //   level: _selectedLevel.replaceAll(' Level', ''),
      //   text: _extractedText,
      //   documentType: _selectedDocType,
      //   fileUrl: '',
      //   timestamp: DateTime.now(),
      // );

      await _documentService.saveDocument(document);
      Provider.of<AppState>(context, listen: false)
          .setCurrentDocument(document);
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

class _DocTypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _DocTypeChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? Colors.blue[800] : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: onSelected,
    );
  }
}
