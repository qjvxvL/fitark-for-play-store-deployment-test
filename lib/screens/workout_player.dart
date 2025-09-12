import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/exercise.dart';
import '../services/tts_service.dart';

class WorkoutPlayer extends StatefulWidget {
  final Exercise exercise;

  const WorkoutPlayer({super.key, required this.exercise});

  @override
  _WorkoutPlayerState createState() => _WorkoutPlayerState();
}

class _WorkoutPlayerState extends State<WorkoutPlayer> {
  final TTSService _tts = TTSService();
  late Timer _timer;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _startWorkout();
  }

  void _startWorkout() {
    _secondsLeft = widget.exercise.duration!;
    _tts.speak("Start ${widget.exercise.name}. ${widget.exercise.instruction}");

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 0) {
        _timer.cancel();
        _tts.speak("${widget.exercise.name} complete! Take a rest.");
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Lottie.asset(widget.exercise.animationAsset, height: 300),
            const SizedBox(height: 20),
            Text(
              widget.exercise.instruction,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              'Time Left: $_secondsLeft s',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
