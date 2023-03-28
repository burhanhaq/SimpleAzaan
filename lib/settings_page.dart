import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: Colors.green,
          height: screenHeight,
          width: 6,
        ),
        const Icon(
          Icons.arrow_forward_ios,
          color: Colors.green,
        )
      ],
    );
  }
}
