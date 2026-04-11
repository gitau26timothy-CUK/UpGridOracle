import 'package:flutter/material.dart';
import 'main_shell.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Consent & Privacy',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.privacy_tip_outlined,
                size: 60, color: Color(0xFF00C853)),
            const SizedBox(height: 24),
            const Text('Your Data, Your Control',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 16),
            const Text(
              'UpGridOracle computes your electricity price signal privately on your device. We collect:',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildPoint(Icons.electric_meter, 'Electricity consumption patterns'),
            _buildPoint(Icons.location_off, 'No GPS or location data'),
            _buildPoint(Icons.phone_android, 'No personal data leaves your device'),
            _buildPoint(Icons.money_off, 'No M-Pesa data in Phase 1'),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  activeColor: const Color(0xFF00C853),
                  onChanged: (val) {
                    setState(() {
                      _agreed = val!;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'I understand and agree to participate in the UpGridOracle Phase 1 pilot',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreed ? const Color(0xFF00C853) : Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _agreed
                    ? () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainShell()),
                        );
                      }
                    : null,
                child: const Text('Join the Pilot',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoint(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00C853), size: 20),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
