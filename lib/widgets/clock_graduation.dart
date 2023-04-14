import 'package:flutter/material.dart';

class ClockGraduation extends StatelessWidget {
  bool isGraduationPassed;
  ClockGraduation({super.key, this.isGraduationPassed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isGraduationPassed ? Colors.black12 : Colors.black54,
      width: 3,
      height: isGraduationPassed ? 15 : 25,
      margin: EdgeInsets.only(bottom: isGraduationPassed ? 225 : 240),
    );
  }
}
