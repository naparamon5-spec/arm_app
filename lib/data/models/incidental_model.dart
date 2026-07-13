class IncidentalModel {
  final String type;
  final String description;

  /// USD amount (`amount_dol`).
  final double amount;

  /// PHP amount (`amount`) straight from the API. When null (e.g. mock data)
  /// the PHP value is derived from [amount] × forex instead.
  final double? amountPhp;

  const IncidentalModel({
    required this.type,
    required this.description,
    required this.amount,
    this.amountPhp,
  });
}
