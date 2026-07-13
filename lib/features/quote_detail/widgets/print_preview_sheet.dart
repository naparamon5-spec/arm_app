import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/quote_model.dart';
import 'approve_bottom_bar.dart' show PrintOption;

class PrintPreviewSheet extends StatelessWidget {
  final QuoteModel quote;
  final PrintOption option;

  const PrintPreviewSheet({
    super.key,
    required this.quote,
    this.option = PrintOption.costing,
  });

  static void show(BuildContext context, QuoteModel quote,
      {PrintOption option = PrintOption.costing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrintPreviewSheet(quote: quote, option: option),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rate = quote.forex;

    if (option == PrintOption.costing) {
      return _Sheet(
        title: 'COSTING SUMMARY',
        quoteNumber: quote.quoteNumber,
        forex: quote.forex,
        colHeader: 'DOLLAR',
        col2Header: 'PHP',
        rows: [
          _Row('SELLING', CurrencyFormatter.usd(quote.billingAmount),
              value2: CurrencyFormatter.php(quote.billingAmount * rate)),
          _Row('BUY PRICE', CurrencyFormatter.usd(quote.buyPrice),
              value2: CurrencyFormatter.php(quote.buyPrice * rate)),
          _Row('INCIDENTAL', CurrencyFormatter.usd(quote.incidentalAmount),
              value2: CurrencyFormatter.php(quote.incidentalAmount * rate)),
          _Row('GP AMT', CurrencyFormatter.usd(quote.gpAmount),
              value2: CurrencyFormatter.php(quote.gpAmount * rate),
              valueColor: quote.gpAmount >= 0
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFFD32F2F)),
          _Row('GP %', CurrencyFormatter.percent(quote.gpPercentage),
              value2: '—', isAccent: true),
        ],
        twoCol: true,
      );
    }

    if (option == PrintOption.dollar) {
      return _Sheet(
        title: 'DOLLAR SUMMARY',
        quoteNumber: quote.quoteNumber,
        forex: quote.forex,
        colHeader: 'DOLLAR',
        rows: [
          _Row('SELLING', CurrencyFormatter.usd(quote.billingAmount)),
          _Row('BUY PRICE', CurrencyFormatter.usd(quote.buyPrice)),
          _Row('INCIDENTAL', CurrencyFormatter.usd(quote.incidentalAmount)),
          _Row('GP AMT', CurrencyFormatter.usd(quote.gpAmount),
              valueColor: quote.gpAmount >= 0
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFFD32F2F)),
          _Row('GP %', CurrencyFormatter.percent(quote.gpPercentage),
              isAccent: true),
        ],
      );
    }

    // PHP
    return _Sheet(
      title: 'PHP SUMMARY',
      quoteNumber: quote.quoteNumber,
      forex: quote.forex,
      colHeader: 'PHP',
      rows: [
        _Row('SELLING', CurrencyFormatter.php(quote.billingAmount * rate)),
        _Row('BUY PRICE', CurrencyFormatter.php(quote.buyPrice * rate)),
        _Row(
            'INCIDENTAL', CurrencyFormatter.php(quote.incidentalAmount * rate)),
        _Row('GP AMT', CurrencyFormatter.php(quote.gpAmount * rate),
            valueColor: quote.gpAmount >= 0
                ? const Color(0xFF1A1A2E)
                : const Color(0xFFD32F2F)),
        _Row('GP %', CurrencyFormatter.percent(quote.gpPercentage),
            isAccent: true),
      ],
    );
  }
}

// ── data model ────────────────────────────────────────────────────────────────

class _Row {
  final String label;
  final String value;
  final String? value2;
  final Color valueColor;
  final bool isAccent;

  const _Row(
    this.label,
    this.value, {
    this.value2,
    this.valueColor = const Color(0xFF1A1A2E),
    this.isAccent = false,
  });
}

// ── sheet container ───────────────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  final String title;
  final String quoteNumber;
  final double forex;
  final String colHeader;
  final String? col2Header;
  final List<_Row> rows;
  final bool twoCol;

  const _Sheet({
    required this.title,
    required this.quoteNumber,
    required this.forex,
    required this.colHeader,
    this.col2Header,
    required this.rows,
    this.twoCol = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Header row
          Row(
            children: [
              const Icon(Icons.print_outlined,
                  size: 18, color: Color(0xFFD32F2F)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                'QT# $quoteNumber',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 4),
          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const SizedBox(width: 100),
                Expanded(
                  child: Text(colHeader,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5),
                      textAlign: TextAlign.right),
                ),
                if (twoCol) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(col2Header ?? '',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 0.5),
                        textAlign: TextAlign.right),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 4),
          // Data rows
          ...rows.map((r) => _RowTile(row: r, twoCol: twoCol)),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 12),
          // Forex
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('FOREX RATE  ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9CA3AF))),
              Text('₱${forex.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── single row tile ───────────────────────────────────────────────────────────

class _RowTile extends StatelessWidget {
  final _Row row;
  final bool twoCol;

  const _RowTile({required this.row, required this.twoCol});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(row.label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.3)),
          ),
          Expanded(
            child: Text(row.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      row.isAccent ? const Color(0xFFD32F2F) : row.valueColor,
                ),
                textAlign: TextAlign.right),
          ),
          if (twoCol) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(row.value2 ?? '—',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: row.isAccent
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.right),
            ),
          ],
        ],
      ),
    );
  }
}
