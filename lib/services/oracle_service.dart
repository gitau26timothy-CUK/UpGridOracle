import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'kplc_data.dart';

class OracleService {
  static final OracleService _instance = OracleService._internal();
  factory OracleService() => _instance;
  OracleService._internal();

  Timer? _timer;
  double _currentRate = 23.45;
  double _gridStress = 0.3; // 0-1
  double _carbonIntensity = 0.2; // 0-1
  double _liquidityIndex = 0.72; // 0-1
  final double alpha = 1.0; // Grid stress weight (EPRA tunable)
  final double beta = 0.8; // Carbon weight
  final double gamma = 0.5; // Liquidity subsidy weight

  // Settlement interval: 15min configurable
  static const Duration interval = Duration(minutes: 15);

  Stream<double> get priceStream => _priceController.stream;
  final StreamController<double> _priceController = StreamController<double>.broadcast();

  Future<void> start() async {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _updatePrice());
    _updatePrice(); // Initial
  }

  Future<void> stop() async {
    _timer?.cancel();
  }

  void _updatePrice() {
    // Mock PPFL on-device computation (Phase 1: local sim)
  final kplc = KPLCDataService();
    _gridStress = (_gridStress + kplc.avgFeederRisk * 0.1 + Random().nextDouble() * 0.1 - 0.05).clamp(0.0, 1.0);
    _carbonIntensity = (_carbonIntensity + Random().nextDouble() * 0.3 - 0.15).clamp(0.0, 1.0);
    _liquidityIndex = 1.0 - kplc.avgFeederRisk * 0.3; // Feeder risk reduces liquidity

    // Pricing integral: simplified discrete (PDF formula)
    _currentRate = 20.0 + 
        alpha * _gridStress * 15 + 
        beta * _carbonIntensity * 18 - 
        gamma * (1 - _liquidityIndex) * 5;

    _priceController.add(_currentRate);
  }

  double get currentRate => _currentRate;
  double get gridStress => _gridStress;
  double get carbonIntensity => _carbonIntensity;
  double get liquidityIndex => _liquidityIndex;
}

class PPFLGradientViz extends StatefulWidget {
  const PPFLGradientViz({super.key});

  @override
  State<PPFLGradientViz> createState() => _PPFLGradientVizState();
}

class _PPFLGradientVizState extends State<PPFLGradientViz> {
  List<double> gradients = [0.0, 0.0, 0.0]; // Mock [G, C, L] updates

  @override
  void initState() {
    super.initState();
    // Simulate local gradient updates every 30s
    Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        gradients = gradients.map((g) => (g + Random().nextDouble() * 0.02 - 0.01).clamp(-0.1, 0.1)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PPFL Shadow (Mock Gradients)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...gradients.asMap().entries.map((entry) {
            final idx = entry.key;
            final grad = entry.value;
            final labels = ['Grid Stress ∇', 'Carbon ∇', 'Liquidity ∇'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(labels[idx], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: (grad + 0.1).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: grad > 0 ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(grad.toStringAsFixed(3), style: TextStyle(color: grad > 0 ? Colors.red : Colors.green)),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text('DP-ε = 1.0 · Local only · No raw data sent',
              style: TextStyle(color: Colors.purple, fontSize: 11)),
        ],
      ),
    );
  }
}
