import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ViewFilesScreen extends StatefulWidget {
  const ViewFilesScreen({super.key});

  @override
  State<ViewFilesScreen> createState() => _ViewFilesScreenState();
}

class _ViewFilesScreenState extends State<ViewFilesScreen> {
  List<File> _pdfFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdfFiles();
  }

  Future<void> _loadPdfFiles() async {
    setState(() {
      _isLoading = true;
    });

    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = await directory.list().toList();
    final List<File> files = entities.whereType<File>().toList();

    // Filter for PDFs and sort by most recent
    _pdfFiles = files.where((file) => file.path.toLowerCase().endsWith('.pdf')).toList();
    _pdfFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File deleted successfully.")),
      );
      _loadPdfFiles(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting file: $e")),
      );
    }
  }

  void _showDeleteConfirmation(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete File?"),
          content: Text("Are you sure you want to delete '${file.path.split('/').last}'?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFile(file);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My PDF Files"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPdfFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfFiles.isEmpty
          ? _buildEmptyFilesState()
          : ListView.builder(
        itemCount: _pdfFiles.length,
        itemBuilder: (context, index) {
          final file = _pdfFiles[index];
          final fileName = file.path.split('/').last;
          final fileStat = file.statSync();
          final fileSize = (fileStat.size / (1024 * 1024)).toStringAsFixed(2); // in MB
          final lastModified = DateFormat('dd MMM yyyy, hh:mm a').format(fileStat.modified);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
              title: Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("$fileSize MB  •  $lastModified"),
              onTap: () => OpenFilex.open(file.path),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'share') {
                    Share.shareXFiles([XFile(file.path)], text: 'Here is my PDF file!');
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(file);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(value: 'share', child: Text('Share')),
                  const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyFilesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 100, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text("No PDFs Found", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text("Create a PDF to see it listed here.", style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}