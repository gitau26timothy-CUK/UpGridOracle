import 'package:flutter/material.dart';
import '../services/kplc_data.dart';

class CarbonBurdenScreen extends StatefulWidget {
  const CarbonBurdenScreen({super.key});

  @override
  State<CarbonBurdenScreen> createState() => _CarbonBurdenScreenState();
}

class _CarbonBurdenScreenState extends State<CarbonBurdenScreen> {
  final KPLCDataService _kplc = KPLCDataService();

  @override
  void initState() {
    super.initState();
    _kplc.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        automaticallyImplyLeading: false,
        title: const Text('Carbon Burden',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<KPLCData>(
              stream: _kplc.dataStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.hourly.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                final hourly = data.hourly;
                final now = hourly.isNotEmpty ? hourly[DateTime.now().hour ~/ 2] : hourly.first;
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _carbonColor(now.carbon).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        const Text('Current Carbon Intensity',
                            style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _sourceIcon(now.source),
                              color: _carbonColor(now.carbon),
                              size: 36,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _carbonLabel(now.carbon),
                              style: TextStyle(
                                  color: _carbonColor(now.carbon),
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(now.carbon * 100).toStringAsFixed(0)}% thermal mix · KES ${now.cost.toStringAsFixed(2)}/kWh',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFFF6D00)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Tip: Shift heavy loads to midnight — save up to KES 16/kWh',
                            style: TextStyle(
                                color: Color(0xFFFF6D00), fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend(const Color(0xFFD50000), 'Dirty'),
                _buildLegend(const Color(0xFFFF6D00), 'High'),
                _buildLegend(const Color(0xFFFFD600), 'Medium'),
                _buildLegend(const Color(0xFF00C853), 'Clean'),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: StreamBuilder<KPLCData>(
              stream: _kplc.dataStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? KPLCData(feeders: [], hourly: []);
                final hourly = data.hourly;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: hourly.length,
                  itemBuilder: (context, index) {
                    final interval = hourly[index];
                    final color = _carbonColor(interval.carbon);
                    final isNow = index == 18;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isNow
                            ? color.withValues(alpha: 0.1)
                            : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isNow
                                ? color.withValues(alpha: 0.6)
                                : color.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _sourceIcon(interval.source),
                            color: color,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('${(interval.hour).toInt() % 24}:00 ${(interval.hour).toInt() % 24 >= 12 ? 'PM' : 'AM'}',
                                        style: TextStyle(
                                            color: isNow
                                                ? Colors.white
                                                : Colors.grey,
                                            fontWeight: isNow
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontSize: 14)),
                                    if (isNow) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('NOW',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(interval.source,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(_carbonLabel(interval.carbon),
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              Text(
                                  'KES ${interval.cost.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: StreamBuilder<KPLCData>(
              stream: _kplc.dataStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? KPLCData(feeders: [], hourly: []);
                      final minCost = data.hourly.isNotEmpty ? data.hourly.map((h) => h.cost).reduce((a, b) => a < b ? a : b) : 0.0;
                final maxCost = data.hourly.isNotEmpty ? data.hourly.map((h) => h.cost).reduce((a, b) => a > b ? a : b) : 0.0;
                final bestHour = data.hourly.isNotEmpty ? data.hourly.reduce((a, b) => a.cost < b.cost ? a : b).hour : 0.0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      Text('KES ${minCost.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: const Color(0xFF00C853),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Text('Cheapest',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ]),
                    Column(children: [
                      Text('KES ${maxCost.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: const Color(0xFFD50000),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Text('Peak',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ]),
                    Column(children: [
                      Text('${bestHour.toInt() % 24}:00',
                          style: TextStyle(
                              color: const Color(0xFF00C853),
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Text('Best time',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _carbonColor(double carbon) {
    if (carbon >= 0.7) return const Color(0xFFD50000);
    if (carbon >= 0.4) return const Color(0xFFFF6D00);
    if (carbon >= 0.2) return const Color(0xFFFFD600);
    return const Color(0xFF00C853);
  }

  String _carbonLabel(double carbon) {
    if (carbon >= 0.7) return 'Dirty';
    if (carbon >= 0.4) return 'High';
    if (carbon >= 0.2) return 'Medium';
    return 'Clean';
  }

  IconData _sourceIcon(String source) {
    if (source == 'Geothermal') return Icons.landscape_outlined;
    if (source == 'Thermal') return Icons.local_fire_department_outlined;
    return Icons.swap_horiz;
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}

