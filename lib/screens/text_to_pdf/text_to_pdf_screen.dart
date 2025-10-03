import 'package:flutter/material.dart';
import 'package:knight_pdf/services/pdf_api_service.dart';
import 'package:open_filex/open_filex.dart';

class TextToPdfScreen extends StatefulWidget {
  const TextToPdfScreen({super.key});

  @override
  State<TextToPdfScreen> createState() => _TextToPdfScreenState();
}

class _TextToPdfScreenState extends State<TextToPdfScreen> {
  final TextEditingController _textController = TextEditingController();
  final PdfApiService _pdfService = PdfApiService();
  bool _isCreating = false;

  Future<void> _createTextPdf() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter some text.")),
      );
      return;
    }

    setState(() { _isCreating = true; });

    try {
      final pdfPath = await _pdfService.createPdfFromText(_textController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("PDF created successfully!"),
        action: SnackBarAction(label: "OPEN", onPressed: () => OpenFilex.open(pdfPath)),
      ));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to create PDF: $e")));
    } finally {
      if(mounted) { setState(() { _isCreating = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text to PDF"),
        actions: [
          if (_isCreating)
            const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: Colors.white))
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _createTextPdf,
              tooltip: "Save as PDF",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: _textController,
          decoration: const InputDecoration(
            hintText: "Enter your text here...",
            border: InputBorder.none,
          ),
          maxLines: null, // Allows for unlimited lines
          expands: true, // Expands to fill the available space
          keyboardType: TextInputType.multiline,
        ),
      ),
    );
  }
}