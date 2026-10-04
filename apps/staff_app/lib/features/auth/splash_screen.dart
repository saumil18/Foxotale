import 'package:flutter/material.dart';

import 'package:foxotale_ui/foxotale_ui.dart';

/// The first frame after the app icon is tapped. Brand shows here, because
/// this is a moment rather than a working screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fox;
    final t = context.type;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset('assets/brand/fox_mark.png', package: 'foxotale_ui',
              width: 96, height: 96, fit: BoxFit.cover),
        ),
        const SizedBox(height: 20),
        FoxBrandText('FoxOtale',
            style: t.wordmark.copyWith(fontSize: 32)),
        const SizedBox(height: 2),
        Text('STAFF APP',
            style: t.label.copyWith(color: c.brandAction, letterSpacing: 3)),
        const SizedBox(height: 14),
        Text('Stay Original, Live the Tale',
            style: TextStyle(
                fontFamily: 'Lora', fontSize: 12.5, color: c.textTertiary)),
      ],
    );

    return Scaffold(
      backgroundColor: c.surfaceSunken,
      body: Center(
        child: reduceMotion
            ? content
            : FadeTransition(
                opacity: CurvedAnimation(
                    parent: _controller, curve: Curves.easeOut),
                child: content,
              ),
      ),
    );
  }
}
