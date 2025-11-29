import 'package:flutter/material.dart';
import 'package:flutter_rotating_menu/rotating_menu_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotating Circular Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Swipe to Rotate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            const RotatingMenuWidget(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Tap any item to see the action',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
