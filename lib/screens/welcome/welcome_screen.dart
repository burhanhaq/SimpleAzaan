import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback? onCollapseCompleted;

  const WelcomeScreen({
    super.key,
    required this.isExpanded,
    this.onCollapseCompleted,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _collapseCompletionSent = false;

  @override
  void didUpdateWidget(covariant WelcomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _collapseCompletionSent = false;
    }
  }

  void _handleAnimationEnd() {
    if (widget.isExpanded || _collapseCompletionSent) {
      return;
    }
    _collapseCompletionSent = true;
    widget.onCollapseCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var screenWidth = screenSize.width;

    var textStyle = TextStyle(
      fontSize: screenWidth * 0.2,
      color: Colors.black,
      fontWeight: FontWeight.w300,
      decoration: TextDecoration.none,
    );
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var maxHeight = constraints.maxHeight;
      var maxWidth = constraints.maxWidth;
      var maxIndividualHeight = maxHeight / 2;
      var borderColor = Colors.black;
      if (!widget.isExpanded) {
        maxIndividualHeight = 0;
        borderColor = const Color(0xfff6f7f9);
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.slowMiddle,
            onEnd: _handleAnimationEnd,
            width: maxWidth,
            height: maxIndividualHeight,
            decoration: BoxDecoration(
              color: const Color(0xfff6f7f9),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Container(
              padding: const EdgeInsets.only(bottom: 30),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Simple',
                  style: textStyle,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.slowMiddle,
            width: maxWidth,
            height: maxIndividualHeight,
            decoration: BoxDecoration(
              color: const Color(0xfff6f7f9),
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Container(
              padding: const EdgeInsets.only(top: 30),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Azaan',
                  style: textStyle,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
