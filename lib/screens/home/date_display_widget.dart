import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_azaan/providers/theme_provider.dart';

class DateDisplayWidget extends StatefulWidget {
  const DateDisplayWidget({super.key, required this.date});
  final String date;

  @override
  State<DateDisplayWidget> createState() => DateDisplayWidgetState();
}

class DateDisplayWidgetState extends State<DateDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenWidth = screenSize.width;
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      children: [
        Text(
          widget.date,
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 24,
            color: themeProvider.primaryTextColor,
            fontWeight: FontWeight.w300,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          height: 1,
          width: screenWidth * 0.6,
          color: themeProvider.dividerColor,
        ),
      ],
    );
  }
}
