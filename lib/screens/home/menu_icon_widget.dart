import 'package:flutter/material.dart';

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
          onPressed: () {},
          iconSize: 24,
          color: Colors.white,
          icon: const Icon(Icons.mosque),
        ),
      ),
    );
  }
}
