import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_lab/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: Image.asset("assets/images/logo.jpg"),
            ),
            const SizedBox(height: 10),
            AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText(
                  'Home Screen',
                  textStyle: const TextStyle(
                    fontFamily: "Dancing",
                    fontSize: 24,
                    color: Colors.red,
                  ),
                ),
                WavyAnimatedText(
                  'Demo AnimatedTextKit',
                  textStyle: const TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 24,
                    color: Colors.blue,
                  ),
                ),
              ],
              isRepeatingAnimation: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
