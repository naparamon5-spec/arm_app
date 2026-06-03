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
  /// BDM (Business Development Manager) name — detail "BDM" field.
  final String bdName;
  /// Business unit group (e.g. "AM", "PDM") — list card "BU GROUP" field.
  final String buGroup;
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
    this.buGroup = '',
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

  /// Safely extracts a String from a value that may be a nested Map
  /// (e.g. the API returns `customer` as `{CUSTOMER_NAME: "Foo"}`).
  static String parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      // salesman object
      return value['FULL_NAME']?.toString()
          ?? value['full_name']?.toString()
          // customer object
          ?? value['CUSTOMER_NAME']?.toString()
          ?? value['customer_name']?.toString()
          // product group object — prefer the short name ("DELL ISG") over the
          // expanded description ("DELL Integrated Solutions Group").
          ?? value['product_group_name']?.toString()
          ?? value['PRODUCT_GROUP_NAME']?.toString()
          ?? value['product_group_desc']?.toString()
          ?? value['PRODUCT_GROUP_DESC']?.toString()
          ?? value['name']?.toString()
          ?? '';
    }
    return value.toString();
  }
  /// Merges this detailed quote (from quotation_header) with the [summary] row
  /// from the "for approval" list (vw_QuoteForApproval). The detail header only
  /// returns codes (customer_code, salesman_code, …) and omits names and the
  /// computed financials, so for every field we keep this quote's value when it
  /// is present and fall back to the summary otherwise. This guarantees the
  /// detail screen shows the same complete data as the list rather than blanks.
  QuoteModel mergedWith(QuoteModel summary) {
    String pick(String a, String b) => a.isNotEmpty ? a : b;
    double pickNum(double a, double b) => a != 0 ? a : b;

    return QuoteModel(
      quoteNumber: pick(quoteNumber, summary.quoteNumber),
      product: pick(product, summary.product),
      customer: pick(customer, summary.customer),
      contactPerson: pick(contactPerson, summary.contactPerson),
      endUser: pick(endUser, summary.endUser),
      customerPO: pick(customerPO, summary.customerPO),
      salesmanName: pick(salesmanName, summary.salesmanName),
      bdName: pick(bdName, summary.bdName),
      buGroup: pick(buGroup, summary.buGroup),
      poNumber: pick(poNumber, summary.poNumber),
      poDate: poDate,
      quoteDate: quoteDate,
      quoteType: pick(quoteType, summary.quoteType),
      term: pick(term, summary.term),
      suContactPerson: pick(suContactPerson, summary.suContactPerson),
      destination: pick(destination, summary.destination),
      billingAmount: pickNum(billingAmount, summary.billingAmount),
      buyPrice: pickNum(buyPrice, summary.buyPrice),
      incidentalAmount: pickNum(incidentalAmount, summary.incidentalAmount),
      gpAmount: pickNum(gpAmount, summary.gpAmount),
      gpPercentage: pickNum(gpPercentage, summary.gpPercentage),
      forex: pickNum(forex, summary.forex),
      allowedUpPercent: pickNum(allowedUpPercent, summary.allowedUpPercent),
      reason: pick(reason, summary.reason),
      status: status,
      items: items,
      incidentals: incidentals,
      attachments: attachments,
      salesmanNote: salesmanNote ?? summary.salesmanNote,
      checking: pick(checking, summary.checking),
    );
  }
}
