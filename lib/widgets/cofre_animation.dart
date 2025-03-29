import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'gems_dialog.dart';

class CofreAnimation extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const CofreAnimation({super.key, required this.onAnimationComplete});

  @override
  _CofreAnimationState createState() => _CofreAnimationState();
}

class _CofreAnimationState extends State<CofreAnimation> {
  late RiveAnimationController _controller;
  bool _animationPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('Shake', autoplay: true);
  }

  void _playGemAnimation() {
    if (_animationPlayed) return;
    setState(() {
      _controller = SimpleAnimation('Gem', autoplay: true);
      _animationPlayed = true;
    });

    // Espera 2 segundos y luego ejecuta la función de completar animación
    Future.delayed(const Duration(seconds: 2), widget.onAnimationComplete);
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showCofreAndGemsDialog(
    BuildContext context, int givenGems, String phrase) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => CofreAnimation(
      onAnimationComplete: () {
        Navigator.of(ctx).pop(); // Cierra el cofre
        Future.delayed(const Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            builder: (ctx) => GemsDialog(
              title: "¡Felicidades, obtuviste $givenGems Gemas!",
              message: phrase,
            ),
          );
        });
      },
    ),
  );
}
