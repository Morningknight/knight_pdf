import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Enum for Image Scale Type
enum ImageScaleType { fit, fill }

class PdfCreationOptions {
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
    final pdf = pw.Document();
    for (var imagePath in imagePaths) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);
        pdf.addPage(pw.Page(
            pageFormat: options.pageFormat,
            build: (pw.Context context) {
              return pw.Center(
                  child: options.scaleType == ImageScaleType.fill
                      ? pw.Image(image,
                      fit: pw.BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity)
                      : pw.Image(image, fit: pw.BoxFit.contain));
            }));
      }
    }
    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = 'KnightPDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> createPdfFromText(String text) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Paragraph(text: text),
          );
        },
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final fileName = 'KnightPDF_Text_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<String> createPdfFromExcel(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final pdf = pw.Document();

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table]!;
      if (sheet.rows.isEmpty) continue;

      final List<List<String>> data = [];
      for (var row in sheet.rows) {
        data.add(row.map((cell) => cell?.value.toString() ?? '').toList());
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) => [
            // --- FIX FOR DEPRECATION WARNING ---
            pw.TableHelper.fromTextArray(
              headers: data.first,
              data: data.sublist(1),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {0: pw.Alignment.centerLeft},
            ),
          ],
        ),
      );
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final originalFileName = filePath.split('/').last.split('.').first;
    final fileName = 'KnightPDF_${originalFileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${outputDir.path}/$fileName');

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}