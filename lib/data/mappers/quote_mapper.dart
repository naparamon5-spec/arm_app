
import '../../core/utils/json_map_extensions.dart';
import '../models/attachment_model.dart';
import '../models/incidental_model.dart';
import '../models/quote_item_model.dart';
import '../models/quote_model.dart';

/// Maps API JSON (vw_QuoteForApproval, quotation_header, etc.) to [QuoteModel].
class QuoteMapper {
  QuoteMapper._();

  static QuoteModel fromListRow(Map<String, dynamic> json) {
    return _fromJson(json);
  }

  static QuoteModel fromHeader(
    Map<String, dynamic> header, {
    List<Map<String, dynamic>> details = const [],
    List<Map<String, dynamic>> tpc = const [],
    List<Map<String, dynamic>> cpoFiles = const [],
  }) {
    return _fromJson(
      header,
      items: details.map(_itemFromJson).toList(),
      incidentals: tpc.map(_incidentalFromJson).toList(),
      attachments: cpoFiles.map(_attachmentFromJson).toList(),
    );
  }

  static QuoteModel _fromJson(
    Map<String, dynamic> json, {
    List<QuoteItemModel>? items,
    List<IncidentalModel>? incidentals,
    List<AttachmentModel>? attachments,
  }) {
    final map = asJsonMap(json);

    final selling = map.dbl([
      'total_selling_price_dol', // vw_QuoteForApproval (list)
      'total_selling_price', // quotation_header (detail)
      'billing_amount', 'billingAmount', 'bill_amt',
    ]);
    final buy = map.dbl([
      'total_buy_price_dol', // list
      'total_buy_price', // detail
      'buy_price', 'buyPrice', 'cost',
    ]);
    // GP amount is only returned directly by the list view (gp_amount_dol);
    // the detail header omits it, so derive it from selling - buy.
    final gp = map.dbl(['gp_amount_dol', 'gp_amount', 'gpAmount', 'gp_amt']);

    return QuoteModel(
      quoteNumber: map.str(['quote_number', 'quoteNumber', 'QT_NO']),
      product: map.str([
        'product_group_name',
        'product_group',
        'product',
        'PRODUCT_GROUP',
      ]),
      customer: QuoteModel.parseString(
        json['customer_name'] ?? json['customer'] ?? json['CUSTOMER_NAME'],
      ),
      contactPerson: QuoteModel.parseString(
        json['customer_contact_person'] ?? json['contact_person'] ??
        json['contactPerson'] ?? json['customer_contact'],
      ),
      endUser: QuoteModel.parseString(
        json['end_user_name'] ?? json['end_user'] ?? json['endUser'],
      ),
      customerPO: map.str(['customer_po', 'customerPO', 'cust_po']),
      salesmanName: QuoteModel.parseString(
        json['salesman'] ?? json['salesman_name'] ?? json['sales_man'] ?? json['SALESMAN_NAME'],
      ),
      // BDM (Business Development Manager) name — distinct from BU group.
      bdName: QuoteModel.parseString(
        json['bdm'] ?? json['bd_name'] ?? json['bdName'] ?? json['bdm_name'] ?? json['bdm_code'],
      ),
      buGroup: map.str(['bu_group', 'BU_GROUP']),
      poNumber: map.str(['po_number', 'poNumber', 'PO_NO']),
      poDate: map.date(['po_date', 'poDate']),
      quoteDate: map.date(['quote_date', 'quoteDate']),
      quoteType: map.str(['quote_type_desc', 'quote_type', 'quoteType', 'type']),
      term: map.str(['TERM_DESCRIPTION', 'term_description', 'term', 'payment_term', 'terms']),
      suContactPerson: QuoteModel.parseString(
        json['eu_contact_person'] ?? json['su_contact_person'] ??
        json['suContactPerson'] ?? json['end_user_contact'],
      ),
      destination: map.str(['destination', 'ship_destination']),
      // SELLING — dollar value (PHP sub-value is computed as value * forex).
      billingAmount: selling,
      buyPrice: buy,
      incidentalAmount: map.dbl([
        'incidental_cost', // list
        'miscellaneous_amount', // detail
        'incidental_amount', 'incidentalAmount', 'tpc_amount',
      ]),
      gpAmount: gp != 0 ? gp : (selling - buy),
      gpPercentage: _gpPercent(map),
      forex: map.dbl(['forex', 'forex_rate']),
      allowedUpPercent: map.dbl([
        'allowed_gp', // list (already a whole percent, e.g. 5)
        'margin', // detail
        'allowed_up_percent', 'allowedUpPercent', 'markup_percent',
      ]),
      reason: map.str(['reason', 'remarks', 'checking_remarks']),
      status: _statusFrom(map.str(['status', 'checking', 'approval_status'])),
      items: items ?? [],
      incidentals: incidentals ?? [],
      attachments: attachments ?? [],
      salesmanNote: _optionalString(map, [
        'salesman_note',
        'salesmanNote',
        'note',
        'approver_remarks',
      ]),
      checking: map.str(['checking', 'CHECKING']),
    );
  }

  static QuoteItemModel _itemFromJson(Map<String, dynamic> json) {
    final map = asJsonMap(json);
    return QuoteItemModel(
      lineType: map.str(['line_type', 'lineType', 'LINE_TYPE']),
      partNumber: map.str(['part_number', 'partNumber', 'PART_NO']),
      description: map.str(['description', 'item_desc', 'DESCRIPTION']),
      itemNumber: map.str(['item_number', 'itemNumber', 'item_no']),
      site: map.str(['site', 'warehouse', 'SITE']),
      quantity: map.integer(['quantity', 'qty', 'QTY']),
      listGlp: map.dbl(['list_glp', 'listGlp', 'list_price']),
      unitPrice: map.dbl(['unit_price', 'unitPrice']),
      extendedPrice: map.dbl(['extended_price', 'extendedPrice', 'amount']),
      freight: map.dbl(['freight', 'freight_amt']),
      vat: map.dbl(['vat', 'vat_amt']),
      costUsd: map.dbl(['cost_usd', 'costUsd']),
      costPhp: map.dbl(['cost_php', 'costPhp']),
      standard: map.str(['standard', 'std']),
    );
  }

  static IncidentalModel _incidentalFromJson(Map<String, dynamic> json) {
    final map = asJsonMap(json);
    return IncidentalModel(
      type: map.str(['type', 'tpc_type', 'incidental_type']),
      description: map.str(['description', 'tpc_desc', 'remarks']),
      amount: map.dbl(['amount', 'tpc_amount', 'incidental_amount']),
    );
  }

  static AttachmentModel _attachmentFromJson(Map<String, dynamic> json) {
    final map = asJsonMap(json);
    final fileName = map.str(['file_name', 'fileName', 'filename', 'name']);
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : map.str(['file_type', 'fileType'], 'file');
    return AttachmentModel(
      fileName: fileName,
      fileType: map.str(['file_type', 'fileType'], ext),
      fileSizeKb: map.dbl(['file_size_kb', 'fileSizeKb', 'size_kb']),
      uploadedDate: map.date(['uploaded_date', 'uploadedDate', 'date_uploaded']),
      url: map.str(['url', 'file_url', 'path', 'file_path']),
    );
  }

  /// GP% is returned as a fraction (`0.05` = 5%) under `gp_perc` /
  /// `overall_gp_percent`. Normalise it to a whole percent for display.
  /// Falls back to legacy keys that already store a percentage.
  static double _gpPercent(Map<String, dynamic> map) {
    final fraction = map.dbl(['gp_perc', 'overall_gp_percent']);
    if (fraction != 0) return fraction * 100;
    return map.dbl(['gp_percentage', 'gpPercentage', 'gp_percent']);
  }

  static QuoteStatus _statusFrom(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('reject')) return QuoteStatus.rejected;
    if (value.contains('approv') || value == 'ok') return QuoteStatus.approved;
    return QuoteStatus.pending;
  }

  static String? _optionalString(Map<String, dynamic> map, List<String> keys) {
    final result = map.str(keys);
    return result.isEmpty ? null : result;
  }
}
