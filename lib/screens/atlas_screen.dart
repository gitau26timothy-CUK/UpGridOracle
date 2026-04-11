import 'package:flutter/material.dart';
import '../services/kplc_data.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AtlasScreen extends StatefulWidget {
  const AtlasScreen({super.key});

  @override
  State<AtlasScreen> createState() => _AtlasScreenState();
}

class _AtlasScreenState extends State<AtlasScreen> {
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
        title: const Text('Grid Equity Atlas',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend(const Color(0xFFD50000), 'High Risk'),
                _buildLegend(const Color(0xFFFF6D00), 'Medium'),
                _buildLegend(const Color(0xFFFFD600), 'Low Risk'),
                _buildLegend(const Color(0xFF00C853), 'Safe'),
              ],
            ),
          ),
  Expanded(
            child: StreamBuilder<KPLCData>(
              stream: _kplc.dataStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? KPLCData(feeders: [], hourly: []);
                return FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(1.2921, 36.8219),
                    initialZoom: 11.0,
                  ),
                  children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.upgridoracle',
                ),
                // Vulnerability Heatmap Polygons
                PolygonLayer(
                  polygons: data.feeders.map((feeder) => Polygon(
                    points: feeder.polygon,
                    color: feeder.risk > 0.75 
                      ? const Color(0x40D50000) 
                      : feeder.risk > 0.5 
                        ? const Color(0x40FF6D00) 
                        : feeder.risk > 0.25 
                          ? const Color(0x40FFD600) 
                          : const Color(0x4000C853),
                    borderColor: _getZoneColor(feeder.risk),
                    borderStrokeWidth: 2.0,
                  )).toList(),
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(1.2921, 36.8219),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
                );
              },
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StreamBuilder<KPLCData>(
              stream: _kplc.dataStream,
              builder: (context, snapshot) {
                final data = snapshot.data ?? KPLCData(feeders: [], hourly: []);
                final totalHh = data.feeders.fold(0, (sum, f) => sum + f.households);
                final highRisk = data.feeders.where((f) => f.risk > 0.75).length;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [
                      Text('$totalHh',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      const Text('Households',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                    Column(children: [
                      Text('$highRisk',
                          style: TextStyle(
                              color: const Color(0xFFD50000),
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      const Text('High Risk',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                    Column(children: [
                      const Text('Live',
                          style: TextStyle(
                              color: Color(0xFF00C853),
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      const Text('Status',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
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

  Color _getZoneColor(double risk) {
    if (risk >= 0.75) return const Color(0xFFD50000);
    if (risk >= 0.5) return const Color(0xFFFF6D00);
    if (risk >= 0.25) return const Color(0xFFFFD600);
    return const Color(0xFF00C853);
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
