import 'package:flutter/material.dart';

class BrandedHeader extends StatelessWidget {
  const BrandedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/ARM.png',
          width: 260,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        const Text(
          'Smart approvals for smart teams',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
