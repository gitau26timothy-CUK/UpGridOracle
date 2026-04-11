import 'package:flutter/material.dart';
import '../services/oracle_service.dart';
import '../services/resilience_credits_service.dart';

class ResilienceCreditsScreen extends StatefulWidget {
  const ResilienceCreditsScreen({super.key});

  @override
  State<ResilienceCreditsScreen> createState() => _ResilienceCreditsScreenState();
}

class _ResilienceCreditsScreenState extends State<ResilienceCreditsScreen> {
  final OracleService _oracle = OracleService();
  final ResilienceCreditsService _creditsService = ResilienceCreditsService();

  @override
  void initState() {
    super.initState();
    _oracle.start();
    _creditsService.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        automaticallyImplyLeading: false,
        title: const Text('Resilience Credits',
            style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFD600), const Color(0xFFFFB300)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD600).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: StreamBuilder<CreditsState>(
                stream: _creditsService.creditsStream,
                builder: (context, snapshot) {
                  final state = snapshot.data ?? CreditsState(balance: 0.0, history: []);
                  return Column(
                    children: [
                      const Text('Your Balance',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      Text('KES ${state.balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1.0)),
                      const Text('Earned this month',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long, color: Colors.black),
                    label: const Text('Apply to Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final currentState = await _creditsService.creditsStream.first;
                      final balance = currentState.balance;
                      await _creditsService.redeem(balance, 'bill');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Applied KES ${balance.toStringAsFixed(2)} to next bill')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people, color: Colors.black),
                    label: const Text('Donate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2979FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final currentState = await _creditsService.creditsStream.first;
                      final balance = currentState.balance;
                      if (balance >= 5.0 && mounted) {
                        await _creditsService.redeem(5.0, 'donate');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Donated KES 5.00 to grid equity fund')),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Activity
            const Text('Recent Credits',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<CreditsState>(
                stream: _creditsService.creditsStream,
                builder: (context, snapshot) {
                  final state = snapshot.data ?? CreditsState(balance: 0.0, history: []);
                  return ListView.separated(
                    itemCount: state.history.length > 5 ? 5 : state.history.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFF2A2A2A),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final credit = state.history[index];
                      final isEarn = credit['amount'] > 0;
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isEarn 
                                ? const Color(0xFF00C853).withValues(alpha: 0.2)
                                : const Color(0xFFFF5722).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isEarn ? Icons.star : Icons.trending_down,
                            color: isEarn ? const Color(0xFF00C853) : const Color(0xFFFF5722),
                            size: 24,
                          ),
                        ),
                        title: Text(credit['reason'],
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(credit['time'],
                            style: const TextStyle(color: Colors.grey)),
                        trailing: Text('KES ${credit['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                                color: credit['amount'] > 0 
                                    ? const Color(0xFFFFD600)
                                    : const Color(0xFFFF5722),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
