import 'package:flutter/material.dart';

/// Map themed splash screen (3 seconds). No extra package needed.
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String appName = 'Map run'; // <- apna app name yaha likho
  static const String tagline = 'Find your way';

  late final AnimationController _controller;
  late final Animation<double> _pinDrop;
  late final Animation<double> _ripple;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // splash duration = 3 sec
    );

    _pinDrop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.bounceOut),
    );
    _ripple = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen),
        );
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _MapPainter()),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final r = _ripple.value;
                final rippleWidth = 40 + 200 * r;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 260,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: ClipOval(
                              child: Container(
                                width: rippleWidth,
                                height: rippleWidth * 0.35,
                                color: Colors.teal
                                    .withAlpha(((1 - r) * 110).round()),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Transform.translate(
                              offset: Offset(0, -(1 - _pinDrop.value) * 220),
                              child: const Icon(
                                Icons.location_on,
                                size: 110,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Opacity(
                      opacity: _textFade.value.clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              appName,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00695C),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              tagline,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a simple city map: park, river, roads.
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFE8F0E6),
    );

    // park
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            size.width * 0.08, size.height * 0.10, size.width * 0.32, size.height * 0.15),
        const Radius.circular(18),
      ),
      Paint()..color = const Color(0xFFC8E6C9),
    );

    // river
    final river = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.55,
          size.width * 0.6, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.92,
          size.width, size.height * 0.80);
    canvas.drawPath(
      river,
      Paint()
        ..color = const Color(0xFFB3D9F2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap = StrokeCap.round,
    );

    // grid roads
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i < 6; i++) {
      final x = size.width * i / 6;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), road);
    }
    for (int i = 1; i < 9; i++) {
      final y = size.height * i / 9;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), road);
    }

    // main highway
    canvas.drawLine(
      Offset(0, size.height * 0.9),
      Offset(size.width, size.height * 0.2),
      Paint()
      //..use?
      // .. Dart ka cascade operator hai.
      // Iska kaam hai ek hi object par ek ke baad ek kai settings lagana,
      // bina baar baar object ka naam likhe.


      //.. ke saath (chhota):
      // dart
      // final paint = Paint()
      //   ..color = const Color(0xFFFFE082)
      //   ..strokeWidth = 20
      //   ..strokeCap = StrokeCap.round;


        // Bina .. ke (lamba):

    //dart
   // final paint = Paint();
    //paint.color = const Color(0xFFFFE082);
    // paint.strokeWidth = 20;
    // paint.strokeCap = StrokeCap.round;
      ..color = const Color(0xFFFFE082)
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
