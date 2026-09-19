import 'package:flutter/material.dart';

class LocationDisplayWidget extends StatelessWidget {
  const LocationDisplayWidget({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        location,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          decoration: TextDecoration.none,
          fontSize: 16,
          color: Colors.black54,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
