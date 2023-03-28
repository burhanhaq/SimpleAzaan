import 'package:flutter/material.dart';

class ClockDial extends StatefulWidget {
  const ClockDial({super.key});

  @override
  State<ClockDial> createState() => _ClockDialState();
}

class _ClockDialState extends State<ClockDial> {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var clockDiameter = screenSize.width / 1.3;

    return Container(
      height: clockDiameter,
      width: clockDiameter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffffffff),
      ),
    );
  }
}
