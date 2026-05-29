class QuoteItemModel {
  final String lineType;
  final String partNumber;
  final String description;
  final String itemNumber;
  final String site;
  final int quantity;
  final double listGlp;
  final double unitPrice;
  final double extendedPrice;
  final double freight;
  final double vat;
  final double costUsd;
  final double costPhp;
  final String standard;

  const QuoteItemModel({
    required this.lineType,
    required this.partNumber,
    required this.description,
    required this.itemNumber,
    required this.site,
    required this.quantity,
    required this.listGlp,
    required this.unitPrice,
    required this.extendedPrice,
    required this.freight,
    required this.vat,
    required this.costUsd,
    required this.costPhp,
    required this.standard,
  });
}
