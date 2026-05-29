class QuoteItemModel {
  final String lineType;
  final String partNumber;
  final String description;
  final String itemNumber;
  final String site;
  final int quantity;
  final double listPrice;
  final double unitPrice;
  final double extendedCost;
  final double rebate;
  final double spu;
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
    required this.listPrice,
    required this.unitPrice,
    required this.extendedCost,
    required this.rebate,
    required this.spu,
    required this.costUsd,
    required this.costPhp,
    required this.standard,
  });
}
