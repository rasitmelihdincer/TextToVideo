import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  final double progress;

  LoadingWidget({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            height: 200,
            width: 200,
            child: Lottie.asset('assets/downloadAnimationLottie.json')),
        SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: TextStyle(color: Colors.tealAccent),
        ),
      ],
    );
  }
}
