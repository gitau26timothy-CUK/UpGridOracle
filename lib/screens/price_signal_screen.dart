import 'package:flutter/material.dart';
import '../services/oracle_service.dart';


class PriceSignalScreen extends StatefulWidget {
  const PriceSignalScreen({super.key});

  @override
  State<PriceSignalScreen> createState() => _PriceSignalScreenState();
}

class _PriceSignalScreenState extends State<PriceSignalScreen> {
  final OracleService _oracle = OracleService();

  @override
  void initState() {
    super.initState();
    _oracle.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        automaticallyImplyLeading: false,
        title: const Text('Live Price Signal',
            style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Live Rate Card
          StreamBuilder<double>(
            stream: _oracle.priceStream,
            builder: (context, snapshot) {
              final rate = snapshot.data ?? _oracle.currentRate;
              final status = _getStatusFromRate(rate);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
border: Border.all(color: status.color.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Text('Current Rate', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      'KES ${rate.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: status.color,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('/kWh', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(status.label, style: TextStyle(color: status.color, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Real-time Metrics
          StreamBuilder<double>(
            stream: _oracle.priceStream,
            builder: (context, snapshot) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMetricTile('Grid Stress', _oracle.gridStress, _getGridColor(_oracle.gridStress))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildMetricTile('Carbon', _oracle.carbonIntensity, _getCarbonColor(_oracle.carbonIntensity))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _buildMetricTile('Liquidity', _oracle.liquidityIndex, const Color(0xFF2979FF)),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Formula Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pricing Formula (PDF)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    children: [
                      const TextSpan(text: 'KES = 20 + '),
                      TextSpan(text: 'α', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan)),
                      const TextSpan(text: '·G×15 + '),
                      TextSpan(text: 'β', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                      const TextSpan(text: '·C×18 - '),
                      TextSpan(text: 'γ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      const TextSpan(text: '·(1-L)×5'),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('α=1.0 β=0.8 γ=0.5 (EPRA)', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: StreamBuilder<double>(
                stream: _oracle.priceStream,
                builder: (context, snapshot) {
                  return Text(
                    'Updated live · Oracle on-device (15min intervals)',
style: TextStyle(color: Colors.grey.withValues(alpha: 0.6), fontSize: 12),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, double value, Color color) {
    final status = _getStatus(value);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Text('${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(status, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  ({Color color, String label}) _getStatusFromRate(double rate) {
    if (rate > 30) return (color: Colors.red, label: 'Peak - High Carbon');
    if (rate > 25) return (color: const Color(0xFFFF6D00), label: 'Elevated');
    if (rate > 20) return (color: const Color(0xFFFFD600), label: 'Normal');
    return (color: const Color(0xFF00C853), label: 'Clean - Geothermal');
  }

  String _getStatus(double value) {
    if (value > 0.7) return 'High';
    if (value > 0.4) return 'Medium';
    return 'Low';
  }

  Color _getGridColor(double value) {
    if (value > 0.7) return Colors.red;
    if (value > 0.4) return const Color(0xFFFF6D00);
    return const Color(0xFF00C853);
  }

  Color _getCarbonColor(double value) {
    if (value > 0.7) return Colors.red;
    if (value > 0.4) return const Color(0xFFFF6D00);
    if (value > 0.2) return const Color(0xFFFFD600);
    return const Color(0xFF00C853);
  }
}

