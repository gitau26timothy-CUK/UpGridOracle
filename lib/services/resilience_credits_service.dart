import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'oracle_service.dart';
import 'kplc_data.dart';

class CreditsState {
  final double balance;
  final List<Map<String, dynamic>> history;
  CreditsState({required this.balance, required this.history});
}

class ResilienceCreditsService {
  static final ResilienceCreditsService _instance = ResilienceCreditsService._internal();
  factory ResilienceCreditsService() => _instance;
  ResilienceCreditsService._internal();

  final StreamController<CreditsState> _creditsController = StreamController<CreditsState>.broadcast();
  Stream<CreditsState> get creditsStream => _creditsController.stream;

  Timer? _earnTimer;
  double _balance = 0.0;
  List<Map<String, dynamic>> _history = [];
  final OracleService _oracle = OracleService();
  final KPLCDataService _kplc = KPLCDataService();

  Future<void> start() async {
    await _loadFromPrefs();
    _earnTimer ??= Timer.periodic(const Duration(minutes: 15), (_) => _autoEarn());
    _autoEarn(); // Initial possible earn
    _creditsController.add(CreditsState(balance: _balance, history: List.from(_history)));
  }

  Future<void> stop() async {
    await _saveToPrefs();
    _earnTimer?.cancel();
  }

  Future<void> _autoEarn() async {
    // Earn formula: base rate * grid risk * factor
    final rate = _oracle.currentRate;
    final risk = _kplc.avgFeederRisk;
    final earned = (rate * risk * 0.1).clamp(0.01, 5.0);
    
    _balance += earned;
    final now = DateTime.now();
    _history.insert(0, {
      'time': '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
      'amount': earned,
      'reason': 'Auto-earn: Grid balancing'
    });
    
    await _saveToPrefs();
    _creditsController.add(CreditsState(balance: _balance, history: List.from(_history)));
  }

  Future<void> redeem(double amount, String type) async {
    if (_balance >= amount) {
      _balance -= amount;
      final now = DateTime.now();
      _history.insert(0, {
        'time': '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
        'amount': -amount,
        'reason': type == 'bill' ? 'Applied to bill' : 'Donated to grid equity'
      });
      
      await _saveToPrefs();
      _creditsController.add(CreditsState(balance: _balance, history: List.from(_history)));
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble('credits_balance') ?? 14.50; // Initial seed
    final historyJson = prefs.getString('credits_history');
    if (historyJson != null) {
      _history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('credits_balance', _balance);
    await prefs.setString('credits_history', jsonEncode(_history));
  }

  void dispose() {
    _earnTimer?.cancel();
    _creditsController.close();
  }
}
