import 'quote_item_model.dart';
import 'incidental_model.dart';
import 'attachment_model.dart';

enum QuoteStatus { pending, approved, rejected }

class QuoteModel {
  final String quoteNumber;
  final String product;
  final String customer;
  final String contactPerson;
  final String endUser;
  final String customerPO;
  final String salesmanName;
  final String bdName;
  final String poNumber;
  final DateTime poDate;
  final DateTime quoteDate;
  final String quoteType;
  final String term;
  final String suContactPerson;
  final String destination;
  final double billingAmount;
  final double buyPrice;
  final double incidentalAmount;
  final double gpAmount;
  final double gpPercentage;
  final double forex;
  final double allowedUpPercent;
  final String reason;
  final QuoteStatus status;
  final List<QuoteItemModel> items;
  final List<IncidentalModel> incidentals;
  final List<AttachmentModel> attachments;
  final String? salesmanNote;
  /// Approval workflow state from API (`checking` column).
  final String checking;

  const QuoteModel({
    required this.quoteNumber,
    required this.product,
    required this.customer,
    required this.contactPerson,
    required this.endUser,
    required this.customerPO,
    required this.salesmanName,
    required this.bdName,
    required this.poNumber,
    required this.poDate,
    required this.quoteDate,
    required this.quoteType,
    required this.term,
    required this.suContactPerson,
    required this.destination,
    required this.billingAmount,
    required this.buyPrice,
    required this.incidentalAmount,
    required this.gpAmount,
    required this.gpPercentage,
    required this.forex,
    required this.allowedUpPercent,
    required this.reason,
    required this.status,
    required this.items,
    required this.incidentals,
    required this.attachments,
    this.salesmanNote,
    this.checking = '',
  });

  bool get requiresRemarksOnApprove =>
      checking.toUpperCase().contains('NEGATIVE GP');
}
