class QuoteItemModel {
  final String lineType;
  final String productCode;
  final String partNumber;
  final String description;
  final String itemNumber;
  final String site;
  final int quantity;
  final double listGlp;
  final double unitPrice;
  final double extendedPrice;
  final double freight;

  /// Freight as a percentage (`freight_percent`).
  final double freightPercent;
  final double vat;

  /// VAT as a percentage (`vat_percent`).
  final double vatPercent;
  final double costUsd;
  final double costPhp;
  final String standard;

  const QuoteItemModel({
    required this.lineType,
    this.productCode = '',
    required this.partNumber,
    required this.description,
    required this.itemNumber,
    required this.site,
    required this.quantity,
    required this.listGlp,
    required this.unitPrice,
    required this.extendedPrice,
    required this.freight,
    this.freightPercent = 0,
    required this.vat,
    this.vatPercent = 0,
    required this.costUsd,
    required this.costPhp,
    required this.standard,
  });
}
