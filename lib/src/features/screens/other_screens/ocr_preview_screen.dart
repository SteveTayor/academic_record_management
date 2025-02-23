import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/document_model.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/service/document_service.dart';
import '../../widgets/sidebar.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String extractedText;

  const DocumentPreviewScreen({
    Key? key,
    required this.extractedText,
  }) : super(key: key);

  @override
  _DocumentPreviewScreenState createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _matricNumberController = TextEditingController();
  final DocumentService _documentService = DocumentService();
  
  String _selectedLevel = '300 Level';
  String _selectedDocType = 'Transcript';
  bool _isSaving = false;

  final List<String> _docTypes = [
    'Transcript',
    'Exam Paper',
    'Research Paper',
    'Letter',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
           Sidebar(selectedMenu: 'Documents', onMenuSelected: (String ) {  },),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumbs(),
                  const SizedBox(height: 20),
                  _buildDocumentPreview(),
                  const SizedBox(height: 24),
                  _buildStudentDetailsForm(),
                  const Spacer(),
                  _buildAdminFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Text(
      'Documents > OCR Upload > Preview',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 14,
      ),
    );
  }

  Widget _buildDocumentPreview() {
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
                child: Text(
                  widget.extractedText,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
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
                  color: Colors.purple[800],
                ),
              ),
              const Divider(height: 30),
              _buildFormField('Student Name', 'Enter student\'s full name'),
              const SizedBox(height: 16),
              _buildFormField('Matric Number', 'Enter matric number'),
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

  Widget _buildFormField(String label, String hint) {
    return TextFormField(
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
          isSelected: List.generate(4, (i) => _selectedLevel == '${(i+1)*100} Level'),
          onPressed: (index) => setState(() {
            _selectedLevel = '${(index+1)*100} Level';
          }),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('100 Level')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('200 Level')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('300 Level')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('400 Level')),
          ],
          color: Colors.grey,
          selectedColor: Colors.white,
          fillColor: Colors.purple[700],
          borderRadius: BorderRadius.circular(8),
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
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedDocType == _docTypes[index]
                    ? Colors.purple[700]
                    : Colors.grey[200],
                foregroundColor: _selectedDocType == _docTypes[index]
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: () => setState(() => _selectedDocType = _docTypes[index]),
              child: Text(_docTypes[index]),
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
          const Text('Admin User', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'System Administrator',
            style: TextStyle(color: Colors.grey[600]),
          ),
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
        userName: _userNameController.text,
        matricNumber: _matricNumberController.text,
        level: _selectedLevel.replaceAll(' Level', ''),
        text: widget.extractedText,
        documentType: _selectedDocType,
        fileUrl: '',
        timestamp: DateTime.now(),
      );

      await _documentService.saveDocument(document);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
}