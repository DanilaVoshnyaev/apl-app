import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../header.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  State<BalancePage> createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  List<dynamic>? _balanceList;
  Map<String, dynamic>? _bonusActivity;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBalances();
  }

  Future<void> _loadBalances() async {
    final app = context.read<AppState>();
    final data = await app.fetchBalances();

    if (data != null) {
      setState(() {
        _balanceList = data['balance'];
        _bonusActivity = data['bonus_activity'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: CustomHeader(),
      drawer: const CustomDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _balanceList == null
              ? Center(child: Text(app.L('fail_load_balance')))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        app.L('balance'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ..._balanceList!.map((balance) {
                      final zone = balance['monetary_zone_data'] ?? {};
                      final name = zone['name'] ?? '—';
                      final currency = zone['currency'] ?? '';
                      final available =
                          balance['available_mv_with_currency'] ?? '0.00';
                      final residual =
                          balance['residual_mv_with_currency'] ?? '0.00';
                      final hold = balance['hold_mv_with_currency'] ?? '0.00';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            '${app.L('wallet_zone')} : $name ($currency)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildRow(
                                    app.L('today_available'),
                                    available,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildRow(
                                    app.L('soon_available'),
                                    residual,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildRow(
                                    app.L('archive'),
                                    hold,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
