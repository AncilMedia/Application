import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  final Widget mobileContent;
  final Widget? tabletSideMenu;
  final Widget? tabletContent;

  const ResponsivePage({
    super.key,
    required this.mobileContent,
    this.tabletSideMenu,
    this.tabletContent,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet layout (600+)
        if (screenWidth >= 600 && tabletSideMenu != null && tabletContent != null) {
          return Row(
            children: [
              Expanded(flex: 1, child: tabletSideMenu!),
              Expanded(flex: 3, child: tabletContent!),
            ],
          );
        }

        // Mobile layout (< 600)
        return mobileContent;
      },
    );
  }
}
