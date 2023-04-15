import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  final bool showWelcomeScreen;
  const WelcomeScreen({super.key, required this.showWelcomeScreen});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var maxHeight = constraints.maxHeight;
      var maxWidth = constraints.maxWidth;
      var maxIndividualHeight = maxHeight / 2;
      var borderColor = Colors.black;
      if (!widget.showWelcomeScreen) {
        maxIndividualHeight = 0;
        borderColor = const Color(0xfff6f7f9);
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.slowMiddle,
            width: maxWidth,
            height: maxIndividualHeight,
            decoration: BoxDecoration(
              color: const Color(0xfff6f7f9),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.slowMiddle,
            width: maxWidth,
            height: maxIndividualHeight,
            decoration: BoxDecoration(
              color: const Color(0xfff6f7f9),
              border: Border(top: BorderSide(color: borderColor)),
            ),
          ),
        ],
      );
    });
  }
}
