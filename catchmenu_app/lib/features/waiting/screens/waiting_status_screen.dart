import 'package:flutter/material.dart';

import '../../../core/storage/guest_session_storage.dart';

class WaitingStatusScreen extends StatefulWidget {
  const WaitingStatusScreen({super.key});

  @override
  State<WaitingStatusScreen> createState() => _WaitingStatusScreenState();
}

class _WaitingStatusScreenState extends State<WaitingStatusScreen> {
  final _storage = const GuestSessionStorage();
  String? _customerId;
  String? _waitingSessionId;

  @override
  void initState() {
    super.initState();
    _loadStoredValues();
  }

  Future<void> _loadStoredValues() async {
    final customerId = await _storage.getGuestCustomerId();
    final waitingSessionId = await _storage.getGuestWaitingSessionId();
    if (!mounted) return;
    setState(() {
      _customerId = customerId;
      _waitingSessionId = waitingSessionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting status')),
      body: RefreshIndicator(
        onRefresh: _loadStoredValues,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Stored guest waiting state',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('guest_customer_id'),
              subtitle: Text(_customerId ?? '(not stored)'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('guest_waiting_session_id'),
              subtitle: Text(_waitingSessionId ?? '(not stored)'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status lookup RPC integration is intentionally not invented in '
              'this change. This screen verifies the persisted ids used by the '
              'waiting status flow boundary.',
            ),
          ],
        ),
      ),
    );
  }
}
