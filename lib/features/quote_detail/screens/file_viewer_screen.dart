import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../data/models/attachment_model.dart';

/// Full-screen, in-app preview of an attachment. Downloads the bytes through
/// the authenticated API client (so protected endpoints work) and renders
/// PDFs and images without leaving the app.
class FileViewerScreen extends StatefulWidget {
  final AttachmentModel attachment;

  const FileViewerScreen({super.key, required this.attachment});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  final _repo = AppDependencies.instance.quoteRepository;

  Uint8List? _bytes;
  PdfController? _pdfController;
  String? _error;
  bool _loading = true;

  static const _imageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

  bool get _isPdf => widget.attachment.fileType.toLowerCase() == 'pdf';
  bool get _isImage => _imageExts.contains(widget.attachment.fileType.toLowerCase());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = widget.attachment.downloadName;
    if (name.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'This file is not available to open.';
      });
      return;
    }

    try {
      final bytes = await _repo.downloadFile(name);
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'The file came back empty.';
        });
        return;
      }
      if (_isPdf) {
        // Open (and await) the document here so a native-renderer failure is
        // caught and shown as an error state instead of crashing the app with
        // an unhandled PlatformException.
        final document = await PdfDocument.openData(bytes);
        if (!mounted) {
          await document.close();
          return;
        }
        _pdfController = PdfController(document: Future.value(document));
      }
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(e);
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textLight,
        title: Text(
          widget.attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _retry);
    }
    if (_isPdf && _pdfController != null) {
      return PdfView(
        controller: _pdfController!,
        scrollDirection: Axis.vertical,
      );
    }
    if (_isImage && _bytes != null) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 5,
        child: Center(child: Image.memory(_bytes!)),
      );
    }
    return _ErrorState(
      message:
          'Preview isn\'t supported for ".${widget.attachment.fileType}" files.',
      onRetry: null,
    );
  }

  String _friendlyError(Exception e) {
    if (e is PlatformException) {
      // Native PDF renderer isn't loaded — almost always a stale build that
      // didn't reinstall the plugin's native code.
      return 'Couldn\'t open the PDF viewer. Please fully close and reopen '
          'the app (a rebuild is needed after updating).';
    }
    return 'Could not open this file. Please try again.';
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _load();
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.insert_drive_file_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                ),
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
