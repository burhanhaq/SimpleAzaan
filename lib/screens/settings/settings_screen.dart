import 'dart:math';

import 'package:flutter/material.dart';
import 'package:simple_azaan/constants.dart';

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
    final settingsScreenWidth =
        settingsScreenOpen ? screenWidth / 1.2 : kSettingsScreenBumpWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedContainer(
          height: screenHeight,
          width: settingsScreenWidth,
          duration: const Duration(microseconds: 9000),
          // curve: Curves.bounceIn,
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              right: BorderSide(
                color: Colors.green.shade700,
                width: kSettingsScreenBumpWidth,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xfff6f7f9),
                    ),
                    Text(
                      'Quakertown, PA',
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 20,
                        color: Color(0xfff6f7f9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              ],
            ),
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
