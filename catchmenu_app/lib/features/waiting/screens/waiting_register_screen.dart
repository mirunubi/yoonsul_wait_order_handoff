import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/guest_session_storage.dart';
import '../../../core/supabase/rpc_caller.dart';

class WaitingRegisterScreen extends ConsumerStatefulWidget {
  const WaitingRegisterScreen({super.key});

  @override
  ConsumerState<WaitingRegisterScreen> createState() =>
      _WaitingRegisterScreenState();
}

class _WaitingRegisterScreenState extends ConsumerState<WaitingRegisterScreen> {
  static const _defaultTenantId = '00000000-0000-0000-0000-000000000001';
  static const _defaultStoreId = '00000000-0000-0000-0000-000000000002';

  final _storage = const GuestSessionStorage();
  final _tenantController = TextEditingController(text: _defaultTenantId);
  final _storeController = TextEditingController(text: _defaultStoreId);
  final _phoneHashController = TextEditingController();

  int _guestCount = 2;
  bool _isLoading = false;
  String? _customerId;
  String? _sessionId;
  String? _message;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStoredIds();
  }

  @override
  void dispose() {
    _tenantController.dispose();
    _storeController.dispose();
    _phoneHashController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredIds() async {
    final customerId = await _storage.getGuestCustomerId();
    final sessionId = await _storage.getGuestWaitingSessionId();
    if (!mounted) return;
    setState(() {
      _customerId = customerId;
      _sessionId = sessionId;
    });
  }

  Future<String> _ensureGuestCustomerId() async {
    final storedCustomerId = await _storage.getGuestCustomerId();
    if (storedCustomerId != null && storedCustomerId.isNotEmpty) {
      return storedCustomerId;
    }

    final rpcCaller = ref.read(rpcCallerProvider);
    final result = await rpcCaller.call<Map<String, dynamic>>(
      'bootstrap_customer_app_v2',
      schema: AppConstants.schemaStore,
      pipeline: AppConstants.pipelineSession,
      module: 'guest_bootstrap',
      flutterScreen: 'waiting_register',
      params: {
        'p_tenant_id': _tenantController.text.trim(),
        'p_store_id': _storeController.text.trim(),
        'p_customer_id': null,
        'p_phone_hash': _nullableText(_phoneHashController.text),
      },
    );

    final response = _asStringMap(result.requireData);
    final data = _asStringMap(response['data']);
    final customer = _asStringMap(data['customer']);
    final customerId = customer['id'] as String?;
    if (customerId == null || customerId.isEmpty) {
      throw StateError(
        'bootstrap_customer_app_v2 did not return data.customer.id',
      );
    }

    await _storage.saveGuestCustomerId(customerId);
    return customerId;
  }

  Future<void> _registerWaiting() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _error = null;
    });

    try {
      final customerId = await _ensureGuestCustomerId();
      final rpcCaller = ref.read(rpcCallerProvider);
      final result = await rpcCaller.call<Map<String, dynamic>>(
        'register_waiting',
        schema: AppConstants.schemaPos,
        pipeline: AppConstants.pipelineWaiting,
        module: 'waiting_register',
        flutterScreen: 'waiting_register',
        params: {
          'p_tenant_id': _tenantController.text.trim(),
          'p_store_id': _storeController.text.trim(),
          'p_session_type': 'WAITING',
          'p_guest_count': _guestCount,
          'p_guest_locale': 'ko',
          'p_phone_hash': _nullableText(_phoneHashController.text),
          'p_customer_id': customerId,
          'p_memo': null,
          'p_source': 'CUSTOMER',
          'p_locale': 'ko',
        },
      );

      final response = _asStringMap(result.requireData);
      final data = _asStringMap(response['data']);
      final sessionId = data['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        throw StateError('register_waiting did not return data.session_id');
      }

      await _storage.saveGuestCustomerId(customerId);
      await _storage.saveGuestWaitingSessionId(sessionId);

      if (!mounted) return;
      setState(() {
        _customerId = customerId;
        _sessionId = sessionId;
        _message = 'Waiting registered. Session: $sessionId';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting registration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tenantController,
            decoration: const InputDecoration(labelText: 'Tenant ID'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _storeController,
            decoration: const InputDecoration(labelText: 'Store ID'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneHashController,
            decoration: const InputDecoration(
              labelText: 'Phone hash (optional)',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Guest count'),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _guestCount,
                items: const [1, 2, 3, 4, 5, 6]
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      ),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _guestCount = value;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isLoading ? null : _registerWaiting,
            child: Text(_isLoading ? 'Registering...' : 'Register waiting'),
          ),
          const SizedBox(height: 24),
          _ValueTile(label: 'guest_customer_id', value: _customerId),
          _ValueTile(label: 'guest_waiting_session_id', value: _sessionId),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: const TextStyle(color: Colors.green)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value ?? '(not stored)'),
    );
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

String? _nullableText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
