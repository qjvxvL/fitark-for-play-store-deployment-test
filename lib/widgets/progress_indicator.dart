import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? color;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget? child;
  final bool showPercentage;
  final TextStyle? textStyle;

  const CustomProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.height = 8.0,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.child,
    this.showPercentage = false,
    this.textStyle,
  });

  @override
  _CustomProgressIndicatorState createState() =>
      _CustomProgressIndicatorState();
}

class _CustomProgressIndicatorState extends State<CustomProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(CustomProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.grey[700],
                borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
              ),
              child: Stack(
                children: [
                  Container(
                    width: (widget.width ?? MediaQuery.of(context).size.width) *
                        _animation.value,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: widget.color ?? Theme.of(context).primaryColor,
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(4.0),
                      gradient: LinearGradient(
                        colors: [
                          widget.color ?? Theme.of(context).primaryColor,
                          (widget.color ?? Theme.of(context).primaryColor)
                              .withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  if (widget.child != null) Center(child: widget.child!),
                ],
              ),
            );
          },
        ),
        if (widget.showPercentage) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '${(_animation.value * 100).toInt()}%',
                style: widget.textStyle ??
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400],
                    ),
              );
            },
          ),
        ],
      ],
    );
  }
}

// Alternative circular progress indicator
class CircularProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final bool showPercentage;

  const CircularProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.size = 80.0,
    this.strokeWidth = 6.0,
    this.child,
    this.showPercentage = false,
  });

  @override
  _CircularProgressIndicatorState createState() =>
      _CircularProgressIndicatorState();
}

class _CircularProgressIndicatorState extends State<CircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(CircularProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CircularProgressPainter(
                  progress: _animation.value,
                  color: widget.color ?? Theme.of(context).primaryColor,
                  backgroundColor: widget.backgroundColor ?? Colors.grey[300]!,
                  strokeWidth: widget.strokeWidth,
                ),
              );
            },
          ),
          if (widget.child != null)
            widget.child!
          else if (widget.showPercentage)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: widget.size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: widget.color ?? Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
