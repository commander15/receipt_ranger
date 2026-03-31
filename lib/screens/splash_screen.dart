import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
<<<<<<< Updated upstream
        child: Image.asset('images/app_icon.png'),
=======
        child: Image.asset('images/app_icon.png', fit: BoxFit.contain),
>>>>>>> Stashed changes
      ),
    );
  }
}
