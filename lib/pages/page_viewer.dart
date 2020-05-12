import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';

class PdfViewerPage extends StatelessWidget {
  final String path;
  final String title;
  const PdfViewerPage({Key key, this.path, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(title: Text(title),),
      path: path,
    );
  }
}