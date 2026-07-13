import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const AppBarWidget({
    super.key,
    this.actions,
    this.automaticallyImplyLeading = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1C2333),
      elevation: 0,
      toolbarHeight: 64,
      titleSpacing: 12,
      automaticallyImplyLeading: false,
      leading: null,
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ARDENT ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'RESOURCE MANAGEMENT',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD32F2F),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: actions,
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: SizedBox(
          height: 2,
          child: ColoredBox(color: Color(0xFFD32F2F)),
        ),
      ),
    );
  }
}
