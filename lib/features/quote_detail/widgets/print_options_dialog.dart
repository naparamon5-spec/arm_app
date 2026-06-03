import 'package:flutter/material.dart';
import 'approve_bottom_bar.dart' show PrintOption;

class PrintOptionsDialog extends StatefulWidget {
  const PrintOptionsDialog({super.key});

  /// Shows the dialog and returns the selected [PrintOption], or null if dismissed.
  static Future<PrintOption?> show(BuildContext context) {
    return showDialog<PrintOption>(
      context: context,
      builder: (_) => const PrintOptionsDialog(),
    );
  }

  @override
  State<PrintOptionsDialog> createState() => _PrintOptionsDialogState();
}

class _PrintOptionsDialogState extends State<PrintOptionsDialog> {
  PrintOption _selected = PrintOption.costing;

  static const _options = [
    (PrintOption.php,     Icons.currency_exchange, 'PHP',     'Values in Philippine Peso (₱)'),
    (PrintOption.dollar,  Icons.attach_money,      'DOLLAR',  'Values in US Dollar (\$)'),
    (PrintOption.costing, Icons.bar_chart,          'COSTING', 'Full costing with \$ and ₱'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── header ──────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.print_outlined,
                    size: 18, color: Color(0xFFD32F2F)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Print Options',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close,
                      size: 20, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a format to preview',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE5E7EB), height: 1),
            const SizedBox(height: 12),
            // ── options ──────────────────────────────────────
            ..._options.map((opt) {
              final (value, icon, label, desc) = opt;
              final selected = _selected == value;
              return GestureDetector(
                onTap: () => setState(() => _selected = value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFFF0F0)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFE5E7EB),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          size: 20,
                          color: selected
                              ? const Color(0xFFD32F2F)
                              : const Color(0xFF6B7280)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 18,
                        color: selected
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFFD1D5DB),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            // ── print button ─────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(_selected),
                icon: const Icon(Icons.print_outlined,
                    size: 18, color: Colors.white),
                label: const Text(
                  'PRINT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
