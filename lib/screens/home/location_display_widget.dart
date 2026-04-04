import 'package:flutter/material.dart';

class LocationDisplayWidget extends StatelessWidget {
  const LocationDisplayWidget({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Text(
      location,
      style: const TextStyle(
        decoration: TextDecoration.none,
        fontSize: 16,
        color: Colors.black54,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}