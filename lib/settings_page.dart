import 'dart:math';

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var settingsPageOpen = false;

  _onPressed() {
    setState(() {
      settingsPageOpen = !settingsPageOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final settingsPageWidth = settingsPageOpen ? screenWidth / 1.2 : 6.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          height: screenHeight,
          width: settingsPageWidth,
          duration: const Duration(microseconds: 9000),
          curve: Curves.bounceIn,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        Transform.translate(
          offset: const Offset(-15, 0),
          child: Transform.rotate(
            angle: settingsPageOpen ? pi : 0,
            child: IconButton(
              onPressed: _onPressed,
              icon: const Icon(Icons.arrow_forward_ios),
              color: Colors.green,
            ),
          ),
        )
      ],
    );
  }
}
