import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

import '../../../core/providers/app_provider.dart';
import '../../widgets/sidebar.dart';
import 'ocr_preview_screen.dart';

class OcrUploadScreen extends StatefulWidget {
  const OcrUploadScreen({Key? key}) : super(key: key);

  @override
  State<OcrUploadScreen> createState() => _OcrUploadScreenState();
}

class _OcrUploadScreenState extends State<OcrUploadScreen> {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();
  bool _isProcessing = false;

  Future<void> _pickAndProcessFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final filePath = result.files.single.path!;
      final text = await _processFile(filePath);

      Provider.of<AppState>(context, listen: false).setExtractedText(text);
      _navigateToPreview(text);
    } catch (e) {
      _showErrorSnackbar('Error processing file: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<String> _processFile(String filePath) async {
    if (filePath.toLowerCase().endsWith('.pdf')) {
      return _processPdf(filePath);
    }
    return _processImage(filePath);
  }

  Future<String> _processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final visionText = await _textRecognizer.processImage(inputImage);
    return visionText.text;
  }

  Future<String> _processPdf(String pdfPath) async {
    final document = await PdfDocument.openFile(pdfPath);
    final tempDir = await getTemporaryDirectory();
    String fullText = '';

    for (var i = 0; i < document.pageCount; i++) {
      final page = await document.getPage(i + 1);
      final image = await page.render(width: 1200, height: 1800);
      final byteData = await image.imageIfAvailable!
          .toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      final tempFile = File('${tempDir.path}/page_$i.png');
      await tempFile.writeAsBytes(pngBytes!);

      final pageText = await _processImage(tempFile.path);
      fullText += '$pageText\n';
      await tempFile.delete();
    }

    await document.dispose();
    return fullText;
  }

  void _navigateToPreview(String text) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentPreviewScreen(
          extractedText: text,
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedMenu: 'Documents',
            onMenuSelected: (menu) {/* Handle navigation */},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Documents > OCR Upload',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildUploadSection(),
                  const SizedBox(height: 24),
                  _buildTextEditorSection(appState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.file_upload, color: Colors.purple),
          const SizedBox(height: 8),
          const Text(
            'Upload File',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a document to extract text using OCR. Supported formats: PDF, PNG, JPG.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isProcessing ? null : _pickAndProcessFile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Choose File'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextEditorSection(AppState appState) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted Text',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Edit extracted text.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: appState.extractedText),
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Extracted text will appear here.',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) => appState.setExtractedText(text),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    _navigateToPreview(appState.extractedText ?? ''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Preview Document'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => _saveTextFile(appState.extractedText ?? ''),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade800),
                ),
                child: const Text('Download Text',
                    style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveTextFile(String text) async {
    final directory = await getDownloadsDirectory();
    if (directory == null) return;

    final file = File(
        '${directory.path}/extracted_text_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(text);
    _showSuccessSnackbar('Text saved to Downloads');
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
