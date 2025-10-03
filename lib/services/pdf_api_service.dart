import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfApiService {
  // Takes a list of image file paths and generates a PDF
  Future<String> createPdfFromImages(List<String> imagePaths) async {
    final pdf = pw.Document();

    // Loop through each image path
    for (var imagePath in imagePaths) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        // Add a new page for each image
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );
      }
    }

    // Get the directory to save the file
    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = 'KnightPDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');

    // Save the PDF and return the file path
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}