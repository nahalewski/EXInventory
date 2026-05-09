import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'user_session.dart';

class _UserEntry {
  final String passwordHash;
  final UserRole role;
  final String displayName;

  const _UserEntry({
    required this.passwordHash,
    required this.role,
    required this.displayName,
  });
}

// Tmp passwords (first login, users should request a change from admin):
//   Bryan   → Bryan123
//   Ben     → Ben123
//   Jared   → Jared123
//   Ann     → Ann123
//   Andrew  → Andrew123
//   David   → David123
class UserCredentials {
  static String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  static final Map<String, _UserEntry> _users = {
    'bryan': _UserEntry(
        passwordHash: _hash('Bryan123'),
        role: UserRole.admin,
        displayName: 'Bryan'),
    'ben': _UserEntry(
        passwordHash: _hash('Ben123'),
        role: UserRole.admin,
        displayName: 'Ben'),
    'jared': _UserEntry(
        passwordHash: _hash('Jared123'),
        role: UserRole.admin,
        displayName: 'Jared'),
    'ann': _UserEntry(
        passwordHash: _hash('Ann123'),
        role: UserRole.standardUser,
        displayName: 'Ann'),
    'andrew': _UserEntry(
        passwordHash: _hash('Andrew123'),
        role: UserRole.standardUser,
        displayName: 'Andrew'),
    'david': _UserEntry(
        passwordHash: _hash('David123'),
        role: UserRole.standardUser,
        displayName: 'David'),
  };

  /// Returns role + display name if credentials match, null otherwise.
  static ({UserRole role, String displayName})? authenticate(
      String username, String password) {
    final normalized = username.trim().toLowerCase();
    final entry = _users[normalized];
    if (entry == null) return null;
    if (_hash(password) != entry.passwordHash) return null;
    return (role: entry.role, displayName: entry.displayName);
  }
}
