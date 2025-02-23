import 'package:archival_system/src/core/service/document_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/model/document_model.dart';
import '../../../core/providers/app_provider.dart';
import '../../widgets/sidebar.dart';

class DocumentPreviewScreen extends StatefulWidget {
  const DocumentPreviewScreen({Key? key}) : super(key: key);

  @override
  _DocumentPreviewScreenState createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _matricNumberController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  String _selectedLevel = '300 Level';
  String _selectedDocumentType = 'Other';
  bool _isSaving = false;
  final DocumentService _documentService = DocumentService();

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _textController.text = appState.extractedText ?? '';
    _selectedDocumentType = appState.documentType;
  }

  Future<void> _saveDocument() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });
      try {
        await _documentService.createOrVerifyUser(
          _userNameController.text,
          _matricNumberController.text,
        );

        final document = DocumentModel(
          id: '',
          userName: _userNameController.text,
          matricNumber: _matricNumberController.text,
          level: _selectedLevel.replaceAll(' Level', ''),
          text: _textController.text,
          documentType: _selectedDocumentType,
          fileUrl: '',
          timestamp: DateTime.now(),
        );

        await _documentService.saveDocument(document);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document saved successfully')),
        );
        Provider.of<AppState>(context, listen: false).setCurrentDocument(document);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving document: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildStructuredView(String documentType, String text) {
    final appState = Provider.of<AppState>(context, listen: false);
    if (documentType == 'Transcript' && appState.currentTranscript != null) {
      final transcript = appState.currentTranscript!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student: ${transcript.student.name}', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Matric Number: ${transcript.student.matricNumber}'),
          Text('Cumulative GPA: ${transcript.cumulativeGpa}'),
          Text('Courses:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...transcript.student.courses.map((course) => Text(
            '- ${course.courseCode} (${course.description}): ${course.remarks} (${course.marksPercentage}%)',
          )),
        ],
      );
    } else if (documentType == 'Letter' && appState.currentDocument?.structuredData != null) {
      final data = appState.currentDocument!.structuredData!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('From: ${data['from'] ?? 'Unknown'}', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('To: ${data['to'] ?? 'Unknown'}'),
          Text('Date: ${data['date'] ?? 'Unknown'}'),
          Text('Body: ${data['body'] ?? text}'),
        ],
      );
    }
    return Text(text);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedMenu: 'Documents',
            onMenuSelected: (menu) {
              // TODO: Handle navigation
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Documents > OCR Upload > Preview',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'Extracted Text',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          _buildStructuredView(_selectedDocumentType, _textController.text),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Student Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'Student Name',
                        hintText: "Enter student's full name",
                        suffixIcon: Icon(Icons.search),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _matricNumberController,
                      decoration: InputDecoration(
                        labelText: 'Matric Number',
                        hintText: 'Enter matric number',
                        suffixIcon: Icon(Icons.camera_alt),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a matric number' : null,
                    ),
                    SizedBox(height: 16),
                    Text('Academic Level', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    ToggleButtons(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('100 Level'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('200 Level'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('300 Level'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('400 Level'),
                        ),
                      ],
                      isSelected: [
                        _selectedLevel == '100 Level',
                        _selectedLevel == '200 Level',
                        _selectedLevel == '300 Level',
                        _selectedLevel == '400 Level',
                      ],
                      onPressed: (index) {
                        setState(() {
                          switch (index) {
                            case 0:
                              _selectedLevel = '100 Level';
                              break;
                            case 1:
                              _selectedLevel = '200 Level';
                              break;
                            case 2:
                              _selectedLevel = '300 Level';
                              break;
                            case 3:
                              _selectedLevel = '400 Level';
                              break;
                          }
                        });
                      },
                      color: Colors.grey,
                      selectedColor: Colors.white,
                      fillColor: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    SizedBox(height: 16),
                    Text('Document Type', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedDocumentType,
                      items: ['Transcript', 'Letter', 'Exam paper', 'Research paper', 'Other']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDocumentType = value!;
                          Provider.of<AppState>(context, listen: false).setDocumentType(value);
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Document Type',
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isSaving
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _saveDocument,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Save Document'),
                              ),
                        SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement cancel logic
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Text('Cancel', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}