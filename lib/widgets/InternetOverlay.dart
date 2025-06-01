import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class InternetOverlay extends StatefulWidget {
  final Widget child;

  const InternetOverlay({super.key, required this.child});

  @override
  State<InternetOverlay> createState() => _InternetOverlayState();
}

class _InternetOverlayState extends State<InternetOverlay> {
  bool _hasInternet = true;
  late StreamSubscription _subscription;

  // Para el control de la animación
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _hasInternet = hasConnection;
        });
      }
    });

    _loadRiveAnimation();
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = result != ConnectivityResult.none;
    });
  }

  Future<void> _loadRiveAnimation() async {
    final data = await RiveFile.asset('assets/images/no_internet.riv');
    final artboard = data.mainArtboard;

    var controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');

    if (controller != null) {
      artboard.addController(controller);
    }

    setState(() {
      _artboard = artboard;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet && _artboard != null)
          Container(
            color: Colors.black.withAlpha(220),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: SizedBox(
                  width: 500,
                  height: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Rive(
                          artboard: _artboard!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Por favor, revisa tu conexión e inténtalo de nuevo.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
