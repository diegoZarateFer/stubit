import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class CofreAnimation extends StatefulWidget {
  const CofreAnimation({super.key});

  @override
  _CofreAnimationState createState() => _CofreAnimationState();
}

class _CofreAnimationState extends State<CofreAnimation> {
  late RiveAnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('Shake', autoplay: true);
  }

  void _playGemAnimation() {
    setState(() {
      _controller = SimpleAnimation('Gem', autoplay: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: GestureDetector(
        onTap: _playGemAnimation,
        child: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación Rive
              SizedBox(
                width: 300,
                height: 300,
                child: RiveAnimation.asset(
                  'assets/images/chest.riv',
                  controllers: [_controller],
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Presiona el cofre para reclamar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
