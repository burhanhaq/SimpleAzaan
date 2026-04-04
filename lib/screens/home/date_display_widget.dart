import 'package:flutter/material.dart';

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

    return Column(
      children: [
        Text(
          widget.date,
          style: const TextStyle(
            decoration: TextDecoration.none,
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w300,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          height: 1,
          width: screenWidth * 0.6,
          color: Colors.black,
        ),
      ],
    );
  }
}
