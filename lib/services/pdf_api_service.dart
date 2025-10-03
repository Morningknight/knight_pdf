import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Enum for Image Scale Type
enum ImageScaleType { fit, fill }

class PdfCreationOptions {
  // Password property is now removed
  final PdfPageFormat pageFormat;
  final ImageScaleType scaleType;

  PdfCreationOptions({
    this.pageFormat = PdfPageFormat.a4,
    this.scaleType = ImageScaleType.fit,
  });
}

class PdfApiService {
  Future<String> createPdfFromImages({
    required List<String> imagePaths,
    required PdfCreationOptions options,
  }) async {
    // Document no longer needs any special parameters
    final pdf = pw.Document();

    for (var imagePath in imagePaths) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: options.pageFormat,
            build: (pw.Context context) {
              return pw.Center(
                child: options.scaleType == ImageScaleType.fill
                    ? pw.Image(image, fit: pw.BoxFit.cover, width: double.infinity, height: double.infinity)
                    : pw.Image(image, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = 'KnightPDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');

    // The save() method is simple again, with no extra parameters
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}