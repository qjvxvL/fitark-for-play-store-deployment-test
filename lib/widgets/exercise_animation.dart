import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ExerciseAnimation extends StatefulWidget {
  final String exerciseType;
  final bool isPlaying;
  final double? width;
  final double? height;
  final Duration? exerciseDuration;
  final VoidCallback? onAnimationFinished;

  const ExerciseAnimation({
    super.key,
    required this.exerciseType,
    this.isPlaying = true,
    this.width = 300,
    this.height = 300,
    this.exerciseDuration,
    this.onAnimationFinished,
  });

  @override
  _ExerciseAnimationState createState() => _ExerciseAnimationState();
}

class _ExerciseAnimationState extends State<ExerciseAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _controller.repeat(reverse: true);
    _breathingController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _controller.stop();
    _breathingController.stop();
  }

  @override
  void didUpdateWidget(ExerciseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _buildExerciseAnimation(),
    );
  }

  Widget _buildExerciseAnimation() {
    // Check if it's a local asset or network URL
    final animationSource = _getAnimationSource(widget.exerciseType);

    if (animationSource != null) {
      if (animationSource.startsWith('assets/')) {
        return _buildLottieAsset(animationSource);
      } else {
        return _buildLottieNetwork(animationSource);
      }
    }else {
      return  _buildCustomAnimation();
    }
  }

  Widget _buildLottieAsset(String assetPath) {
    return Lottie.asset(
      assetPath,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      repeat: widget.isPlaying,
    );
  }

  Widget _buildLottieNetwork(String url) {
    return Lottie.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      repeat: widget.isPlaying,
      errorBuilder: (context, error, stackTrace) {

        return _buildCustomAnimation();
      },
    );
  }

  Widget _buildCustomAnimation() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _breathingAnimation.value,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getExerciseIcon(widget.exerciseType),
                        size: (widget.width ?? 300) * 0.3,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.exerciseType.toUpperCase(),
                        style: TextStyle(
                          fontSize: (widget.width ?? 300) * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getExerciseIcon(String exerciseType) {
    final exerciseIcons = {
      'push-ups': Icons.fitness_center,
      'squats': Icons.accessibility_new,
      'free inchworm': Icons.trending_down,
      'jumping jacks': Icons.directions_run,
      'plank': Icons.remove,
      'mountain climbers': Icons.terrain,
      'burpees': Icons.sports_gymnastics,
    };

    return exerciseIcons[exerciseType.toLowerCase()] ?? Icons.sports;
  }



  String? _getAnimationSource(String exerciseType) {
    // Free Lottie animations from LottieFiles
    final animationSources = {
      'push-ups': 'assets/animations/wide_arm_push_up.json',
      'squats': 'assets/animations/squat reach.json',
      'free inchworm': 'assets/animations/inchworm.json',
      'jumping jacks':
          'https://assets2.lottiefiles.com/packages/lf20_kxjjjb9l.json',
      'plank': 'https://assets2.lottiefiles.com/packages/lf20_z3lqoqkx.json',
      'mountain climbers':
          'https://assets2.lottiefiles.com/packages/lf20_dmkqrzer.json',
      'burpee': 'assets/animations/burpee_exercise.json',
    };

    return animationSources[exerciseType.toLowerCase()];
  }
}


  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

