import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTabTap;
  const HomeScreen({super.key, required this.onTabTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.bolt, color: Color(0xFF00C853)),
            SizedBox(width: 8),
            Text('UpGridOracle',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome to the Pilot',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 6),
            const Text('500 households · Nairobi · Phase 1',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 30),

            _buildCard(
              icon: Icons.electric_bolt,
              title: 'Live Price Signal',
              subtitle: 'Your current electricity rate in KES',
              color: const Color(0xFF00C853),
              tag: 'KES 23.45/kWh',
              onTap: () => onTabTap(1),
            ),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.map_outlined,
              title: 'Grid Equity Atlas',
              subtitle: 'Nairobi vulnerability heatmap',
              color: const Color(0xFF2979FF),
              tag: '4 high risk zones',
              onTap: () => onTabTap(2),
            ),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.eco_outlined,
              title: 'Carbon Burden',
              subtitle: 'Live carbon intensity overlay',
              color: const Color(0xFFFF6D00),
              tag: 'Thermal active now',
              onTap: () => onTabTap(3),
            ),
            const SizedBox(height: 16),

            _buildCard(
              icon: Icons.stars,
              title: 'Resilience Credits',
              subtitle: 'Your earned grid-balancing rewards',
              color: const Color(0xFFFFD600),
              tag: 'KES 14.50 earned',
              onTap: () => onTabTap(4),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.circle, color: Color(0xFF00C853), size: 12),
                  SizedBox(width: 8),
                  Text('Oracle active · Computing on-device',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String tag,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(tag,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
