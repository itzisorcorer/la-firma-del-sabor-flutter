import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_firma_sabor/constants/app_theme.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String creatorName;

  const PdfViewerScreen({super.key, required this.pdfUrl, required this.creatorName});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }


// 👇 Descarga usando CacheManager (A prueba de balas y cortes de servidor)
  Future<void> _fetchPdf() async {
    try {
      print('📥 Intentando descargar y cachear PDF desde: ${widget.pdfUrl}');

      // El CacheManager se encarga de pelear con la red lenta y los cortes
      final file = await DefaultCacheManager().getSingleFile(widget.pdfUrl);

      print('✅ PDF guardado en caché del celular exitosamente.');

      // Extraemos los bytes del archivo físico que ya se descargó
      final bytes = await file.readAsBytes();

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('💥 Excepción al descargar/leer PDF: $e');
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    }
  }

  // Función para "Descargar" (Se mantiene intacta)
  Future<void> _downloadPdf(BuildContext context) async {
    final Uri url = Uri.parse(widget.pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace de descarga'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.brandYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Biografía: ${widget.creatorName}', style: const TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppTheme.navyBlue),
            tooltip: 'Descargar archivo',
            onPressed: () => _downloadPdf(context),
          )
        ],
      ),
      // 👇 Mostramos estados de carga, error o dibujamos desde la memoria
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.orangeBrand),
            SizedBox(height: 15),
            Text("Cargando documento...", style: TextStyle(color: AppTheme.navyBlue, fontWeight: FontWeight.bold))
          ],
        ),
      )
          : _hasError || _pdfBytes == null
          ? const Center(child: Text("Ocurrió un error al cargar el PDF...", style: TextStyle(color: Colors.red, fontSize: 16)))
          : SfPdfViewer.memory(
        _pdfBytes!,
        canShowScrollHead: false,
      ),
    );
  }
}