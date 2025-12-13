import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.handyman, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Service Marketplace',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
