class AttachmentModel {
  final String fileName;
  final String fileType;
  final double fileSizeKb;
  final DateTime uploadedDate;
  final String url;

  const AttachmentModel({
    required this.fileName,
    required this.fileType,
    required this.fileSizeKb,
    required this.uploadedDate,
    required this.url,
  });
}
