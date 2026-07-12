import 'package:shared_preferences/shared_preferences.dart';

/// Stores non-sensitive guest identity/session values for the waiting flow.
class GuestSessionStorage {
  static const String guestCustomerIdKey = 'guest_customer_id';
  static const String guestWaitingSessionIdKey = 'guest_waiting_session_id';

  const GuestSessionStorage();

  Future<String?> getGuestCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(guestCustomerIdKey);
  }

  Future<void> saveGuestCustomerId(String customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(guestCustomerIdKey, customerId);
  }

  Future<String?> getGuestWaitingSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(guestWaitingSessionIdKey);
  }

  Future<void> saveGuestWaitingSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(guestWaitingSessionIdKey, sessionId);
  }
}
