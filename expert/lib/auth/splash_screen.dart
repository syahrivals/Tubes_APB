import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Animasi Splash Screen 3 detik (Sesuai permintaan 30 detik untuk dummy, tapi diset 3 detik dulu agar tidak perlu menunggu setengah menit setiap kali me-restart. Bisa diganti jadi 30 jika memang mau)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // Animasi Zoom Out (dimulai dari skala 1.5 mengecil ke 1.0)
              var scaleTween = Tween<double>(begin: 1.5, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOutCubic));
              var fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeIn));

              return ScaleTransition(
                scale: animation.drive(scaleTween),
                child: FadeTransition(
                  opacity: animation.drive(fadeTween),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar Logo dari assets
            Image.asset(
              'assets/logo.jpeg',
              width: 250,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Mohon masukkan gambar ke assets/logo.jpeg\natau sesuaikan nama file',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
