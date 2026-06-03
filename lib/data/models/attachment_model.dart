class AttachmentModel {
  final String fileName;
  final String fileType;
  final double fileSizeKb;
  final DateTime uploadedDate;
  final String url;

  /// Stored (server-side) filename passed to
  /// `GET /api/quote-approvals/files/:filename` to fetch the bytes.
  final String downloadName;

  const AttachmentModel({
    required this.fileName,
    required this.fileType,
    required this.fileSizeKb,
    required this.uploadedDate,
    required this.url,
    this.downloadName = '',
  });
}
