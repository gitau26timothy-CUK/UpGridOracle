import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';

class KPLCDataService {
  static final KPLCDataService _instance = KPLCDataService._internal();
  factory KPLCDataService() => _instance;
  KPLCDataService._internal();

  Timer? _timer;
  final StreamController<KPLCData> _dataController = StreamController<KPLCData>.broadcast();

  Stream<KPLCData> get dataStream => _dataController.stream;

  List<FeederZone> _feeders = [];
  List<HourlyInterval> _hourly = [];
  double _avgRisk = 0.0;

  Future<void> start() async {
    await _loadMockData();
_timer = Timer.periodic(const Duration(seconds: 10), (_) => _simulateUpdate());
    _simulateUpdate();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _dataController.close();
  }

  Future<void> _loadMockData() async {
    _feeders = [
      FeederZone(
        name: 'Kibera 11kV',
        risk: 0.92,
        households: 1240,
        polygon: [
          LatLng(1.2975, 36.7960),
          LatLng(1.2950, 36.8000),
          LatLng(1.2920, 36.7980),
          LatLng(1.2940, 36.7940),
        ],
      ),
      FeederZone(
        name: 'Mathare 33kV',
        risk: 0.88,
        households: 890,
        polygon: [
          LatLng(1.2500, 36.8700),
          LatLng(1.2480, 36.8720),
          LatLng(1.2460, 36.8680),
          LatLng(1.2490, 36.8650),
        ],
      ),
    ];
_hourly = List.generate(24, (i) => HourlyInterval(
      hour: i * 1.0,
      carbon: 0.05 + sin(i / 24 * 2 * pi) * 0.4,
      cost: 17.5 + i * 0.8,
      source: _getSource(i),
    )); 
    _dataController.add(KPLCData(feeders: _feeders, hourly: _hourly));
  }

  void _simulateUpdate() {
    for (var feeder in _feeders) {
      feeder.risk = (feeder.risk + Random().nextDouble() * 0.05 - 0.025).clamp(0.0, 1.0);
    }
    _avgRisk = _feeders.isNotEmpty ? _feeders.map((f) => f.risk * f.households).reduce((a, b) => a + b) / _feeders.map((f) => f.households).reduce((a, b) => a + b) : 0.3;
    for (var h in _hourly) {
      h.carbon += Random().nextDouble() * 0.02 - 0.01;
      h.cost += Random().nextDouble() * 0.5 - 0.25;
    }
    _dataController.add(KPLCData(feeders: _feeders, hourly: _hourly, avgRisk: _avgRisk));
  }

  String _getSource(int hour) {
    if (hour >= 14 && hour <= 22) return 'Thermal';
    if (hour >= 8 && hour <= 14) return 'Mixed';
    return 'Geothermal';
  }

  double get avgFeederRisk => _avgRisk > 0 ? _avgRisk : 0.3;
}

class KPLCData {
  final List<FeederZone> feeders;
  final List<HourlyInterval> hourly;
  final double avgRisk;
  KPLCData({required this.feeders, required this.hourly, this.avgRisk = 0.0});
}

class FeederZone {
  String name;
  double risk;
  int households;
  List<LatLng> polygon;
  FeederZone({required this.name, required this.risk, required this.households, required this.polygon});
}

class HourlyInterval {
  final double hour;
  double carbon;
  double cost;
  String source;
  HourlyInterval({required this.hour, required this.carbon, required this.cost, required this.source});
}

