// widgets/jedi_app_bar.dart
import 'package:flutter/material.dart';

class JediAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const JediAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.blueGrey.shade900,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.5),
              blurRadius: 60,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          title.toLowerCase(),
          style: const TextStyle(
            fontFamily: 'StarWars',
            fontSize: 36,
            color: Color.fromARGB(255, 250, 250, 129),
            shadows: [
              Shadow(
                color: Color.fromARGB(255, 144, 144, 97),
                blurRadius: 15.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
