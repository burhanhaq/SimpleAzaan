import 'dart:math';

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var settingsScreenOpen = false;

  _onPressed() {
    setState(() {
      settingsScreenOpen = !settingsScreenOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;
    final settingsScreenWidth = settingsScreenOpen ? screenWidth / 1.2 : 6.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          height: screenHeight,
          width: settingsScreenWidth,
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
            angle: settingsScreenOpen ? pi : 0,
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
