import 'package:flutter/material.dart';
import '../security/security_guard.dart';

class CryoSplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const CryoSplashScreen({super.key, required this.nextScreen});

  @override
  State<CryoSplashScreen> createState() => _CryoSplashScreenState();
}

class _CryoSplashScreenState extends State<CryoSplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2100), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D19),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 1.1,
            colors: [Color(0xFF102547), Color(0xFF070D19)],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withAlpha(85),
                        blurRadius: 32,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF0F2547),
                      alignment: Alignment.center,
                      child: const Icon(Icons.ac_unit_rounded, color: Color(0xFF38BDF8), size: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'CryoCalc PRO',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  '${CryoOwner.developerAr} 🇩🇿',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                ),
                const SizedBox(height: 4),
                const Text(
                  CryoOwner.groupCode,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: Color(0xFFF59E0B)),
                ),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 110,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    backgroundColor: Color(0xFF111D34),
                    valueColor: AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '100% بدون إنترنت • محصّن • 0% إعلانات',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
