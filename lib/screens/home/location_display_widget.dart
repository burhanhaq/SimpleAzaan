import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_azaan/providers/theme_provider.dart';

class LocationDisplayWidget extends StatelessWidget {
  const LocationDisplayWidget({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Text(
      location,
      style: TextStyle(
        decoration: TextDecoration.none,
        fontSize: 16,
        color: themeProvider.secondaryTextColor,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}