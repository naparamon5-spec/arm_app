import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/quote_model.dart';

class ApprovalCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onTap;

  const ApprovalCard({super.key, required this.quote, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD32F2F), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1 — Quote Number
            const Text(
              'QUOTE NUMBER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              quote.quoteNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            // Divider after quote number
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
            ),
            // Row 2 — Product & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _FieldCol(label: 'PRODUCT', value: quote.product),
                ),
                const SizedBox(width: 16),
                _FieldCol(
                  label: 'DATE',
                  value: DateFormatter.display(quote.quoteDate),
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 3 — Customer & BU Group
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _FieldCol(label: 'CUSTOMER', value: quote.customer),
                ),
                const SizedBox(width: 16),
                _FieldCol(
                  label: 'BU GROUP',
                  value: quote.buGroup,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ],
            ),
            // Divider after customer row
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
            ),
            // Row 4 — Salesman pill row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE5E7EB),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Sales: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          TextSpan(
                            text: quote.salesmanName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
            // Salesman note — only if present
            if (quote.salesmanNote != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 3,
                        color: const Color(0xFFD32F2F),
                      ),
                      Expanded(
                        child: Container(
                          color: const Color(0xFFE8EAF6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            quote.salesmanNote!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldCol extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  const _FieldCol({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
