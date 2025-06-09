import 'package:flutter/material.dart';

class CustomTextScale extends StatelessWidget {
  final Widget child;
  final double scaleFactor;

  const CustomTextScale({
    Key? key,
    required this.child,
    this.scaleFactor = 0.85,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: scaleFactor),
      child: child,
    );
  }
}