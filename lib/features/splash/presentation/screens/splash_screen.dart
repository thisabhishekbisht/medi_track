import 'package:flutter/material.dart';
import '../../../../core/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    // Simulate a delay for the splash screen
    await Future.delayed(const Duration(seconds: 2), () {});
    // Replace the current screen with the medicine list screen
    Navigator.of(context).pushReplacementNamed(AppRoutes.medicineList);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100), // Or your app logo
            SizedBox(height: 20),
            Text(
              'Medi-Track',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
