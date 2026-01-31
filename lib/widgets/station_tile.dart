import 'package:flutter/material.dart';

class StationTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const StationTile({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.yellow.withOpacity(0.2) : Colors.grey[900],
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.yellow : Colors.white,
            fontFamily: 'StarWars', // Dein Font!
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.graphic_eq, color: Colors.yellow)
            : null,
        onTap: onTap,
      ),
    );
  }
}
