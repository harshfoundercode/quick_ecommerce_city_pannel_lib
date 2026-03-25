import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'invoice_mobile.dart'
if (dart.library.html) 'invoice_web.dart';

class InvoiceService {
  static Future<void> saveAndOpen(
      BuildContext context,
      Uint8List pdfBytes,
      String fileName,
      ) async {
    try {
      await saveFile(pdfBytes, fileName);
    } catch (e) {
      debugPrint("PDF ERROR: $e");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}