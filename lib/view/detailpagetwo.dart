import 'package:flutter/material.dart';

import 'Responsive/Responsive_font.dart';

class Detailspagetwo extends StatefulWidget {
  const Detailspagetwo({super.key});

  @override
  State<Detailspagetwo> createState() => _DetailspagetwoState();
}

class _DetailspagetwoState extends State<Detailspagetwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: CustomTextScale(child: Text('Content')))
        ],
      ),
    );
  }
}
