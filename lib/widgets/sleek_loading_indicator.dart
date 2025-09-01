import 'package:flutter/material.dart';
import 'package:simple_azaan/constants.dart';

class SleekLoadingIndicator extends StatefulWidget {
  final String? message;
  final double? width;
  final double height;
  final Color primaryColor;
  final Color backgroundColor;
  final Duration animationDuration;

  const SleekLoadingIndicator({
    super.key,
    this.message,
    this.width,
    this.height = 4.0,
    this.primaryColor = Colors.black,
    this.backgroundColor = kLoadingBackgroundColor,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<SleekLoadingIndicator> createState() => _SleekLoadingIndicatorState();
}

class _SleekLoadingIndicatorState extends State<SleekLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.message != null) ...[
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LoadingPainter(
                    progress: _animation.value,
                    primaryColor: widget.primaryColor,
                    backgroundColor: widget.backgroundColor,
                  ),
                );
              },
            ),
          ),
          if (widget.message != null) const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  _LoadingPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderRadius = size.height / 2;
    
    // Clip to rounded rectangle background
    final clipPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));
    
    canvas.clipPath(clipPath);
    
    // Create a moving black bar
    final barWidth = size.width * 0.3; // Bar takes up 30% of total width
    final maxPosition = size.width - barWidth;
    final barPosition = maxPosition * progress;
    
    final barPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    // Draw the moving black bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(barPosition, 0, barWidth, size.height),
        Radius.circular(borderRadius),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Alternative simpler version with just moving bars
class SimpleHorizontalLoader extends StatefulWidget {
  final String? message;
  final double? width;
  final double height;
  final Color primaryColor;
  final Color backgroundColor;

  const SimpleHorizontalLoader({
    super.key,
    this.message,
    this.width,
    this.height = 4.0,
    this.primaryColor = kPrimaryColor,
    this.backgroundColor = kLoadingBackgroundColor,
  });

  @override
  State<SimpleHorizontalLoader> createState() => _SimpleHorizontalLoaderState();
}

class _SimpleHorizontalLoaderState extends State<SimpleHorizontalLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message != null) ...[
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],
        Container(
          width: widget.width ?? 200,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: null, // Indeterminate
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                minHeight: widget.height,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}