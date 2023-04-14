import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:flutter/material.dart';

class GoToTodayWidget extends StatelessWidget {
  const GoToTodayWidget(
      {super.key, this.offstage = true, required this.tapHandler});
  final bool offstage;
  final VoidCallback tapHandler;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 30,
      bottom: 30,
      child: Offstage(
        offstage: offstage,
        child: GestureDetector(
          onTap: tapHandler,
          child: const Text(
            'Go To\nToday',
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
