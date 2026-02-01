import 'package:flutter/material.dart';
import '../senderliste.dart';

class StationList extends StatelessWidget {
  final String currentStation;
  final Function(String name, String url) onStationTap;

  const StationList({
    super.key,
    required this.currentStation,
    required this.onStationTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stations.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final station = stations[index];
        final String name = station['name'] ?? 'Unbekannt';
        final String url = station['url'] ?? '';
        final String? logoPath = station['logo'];
        final bool isSelected = currentStation == name;

        // Die Farbe des Lasers: Cyan für bereit, Gelb/Gold für aktiv (Jedi-Style)
        final Color laserColor = isSelected
            ? Colors.yellowAccent
            : Colors.cyanAccent;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          decoration: BoxDecoration(
            // Tiefschwarzer Hintergrund für maximalen Kontrast
            color: const Color(0xFF0A0E14),
            borderRadius: BorderRadius.circular(20),
            // Der "Laser"-Rahmen
            border: Border.all(
              color: laserColor.withOpacity(isSelected ? 0.8 : 0.3),
              width: isSelected ? 2.0 : 1.0,
            ),
            // Der Glow-Effekt nach außen
            boxShadow: [
              BoxShadow(
                color: laserColor.withOpacity(isSelected ? 0.2 : 0.05),
                blurRadius: isSelected ? 15 : 5,
                spreadRadius: 1,
              ),
            ],
          ),
          // ... im ListTile innerhalb der StationList
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            // HIER war der Fehler: Du musst die Funktion aufrufen!
            leading: _buildLeading(logoPath, laserColor),

            title: Text(
              name.toUpperCase(), // ...
              style: TextStyle(
                color: isSelected ? laserColor : Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
                shadows: [
                  if (isSelected) Shadow(color: laserColor, blurRadius: 10),
                ],
              ),
            ),
            subtitle: Text(
              isSelected ? ">> TRANSMITTING..." : ">> READY_TO_STREAM",
              style: TextStyle(
                color: laserColor.withOpacity(0.5),
                fontSize: 9,
                fontFamily: 'Courier',
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.bolt : Icons.arrow_forward_ios,
              color: laserColor.withOpacity(0.5),
              size: 16,
            ),
            onTap: () => onStationTap(name, url),
          ),
        );
      },
    );
  }

  // Hier fügen wir die laserColor als zweiten Parameter hinzu
  Widget _buildLeading(String? logoPath, Color laserColor) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: laserColor.withOpacity(
              0.3,
            ), // Jetzt leuchtet das Logo passend!
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.black,
        backgroundImage: logoPath != null ? AssetImage(logoPath) : null,
        child: logoPath == null ? Icon(Icons.radio, color: laserColor) : null,
      ),
    );
  }
}
