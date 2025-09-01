import 'package:flutter/material.dart';
import 'package:simple_azaan/screens/settings/settings_screen.dart';

class MenuIconWidget extends StatefulWidget {
  const MenuIconWidget({super.key});

  @override
  State<MenuIconWidget> createState() => _MenuIconWidgetState();
}

class _MenuIconWidgetState extends State<MenuIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 30,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          iconSize: 24,
          color: Colors.white,
          icon: const Icon(Icons.mosque),
        ),
      ),
    );
  }
}
