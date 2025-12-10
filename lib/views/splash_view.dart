import 'package:flutter/material.dart';
import 'package:bloomy/views/onBoarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnBoardingView()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 350, 
              height: 300,
            ),
            const SizedBox(height: 0),
            const Text(
              'Bloom Your Mood',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Color(0xFF064232),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
