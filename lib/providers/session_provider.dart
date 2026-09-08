import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';
import '../services/user_service.dart';

enum SessionStatus { restoring, signedOut, authenticating, signedIn }

class SessionProvider extends ChangeNotifier {
  SessionProvider({UserService? userService})
    : _userService = userService ?? UserService();

  final UserService _userService;

  SessionStatus _status = SessionStatus.restoring;
  User? _user;
  String? _errorMessage;

  SessionStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _status == SessionStatus.signedIn && _user != null;

  Future<void> restoreSession() async {
    _status = SessionStatus.restoring;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(storedUserKey);
    if (saved == null || saved.isEmpty) {
      _setSignedOut();
      return;
    }

    try {
      final decoded = jsonDecode(saved);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid stored user data.');
      }

      final cachedUser = User.fromJson(decoded);
      if (cachedUser.accessToken.isEmpty) {
        throw const FormatException('Stored session has no access token.');
      }

      try {
        final refreshed = await _userService.getAuthenticatedUser(
          cachedUser.accessToken,
        );
        _user = refreshed.copyWith(refreshToken: cachedUser.refreshToken);
        await _persistUser(_user!);
      } on ApiException catch (error) {
        if (error.statusCode == 401 || error.statusCode == 403) {
          await preferences.remove(storedUserKey);
          _setSignedOut();
          return;
        }
        _user = cachedUser;
      } catch (_) {
        // Keep the cached profile for a deterministic offline start. Individual
        // screens still show retry UI when their live requests fail.
        _user = cachedUser;
      }
      _status = SessionStatus.signedIn;
      _errorMessage = null;
      notifyListeners();
    } catch (_) {
      await preferences.remove(storedUserKey);
      _setSignedOut();
    }
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    _status = SessionStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _userService.login(username: username, password: password);
      await _persistUser(_user!);
      _status = SessionStatus.signedIn;
      notifyListeners();
      return true;
    } catch (error) {
      _user = null;
      _status = SessionStatus.signedOut;
      _errorMessage = error is ApiException
          ? error.message
          : 'We could not connect to DummyJSON. Check your connection.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storedUserKey);
    _setSignedOut();
  }

  Future<void> _persistUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storedUserKey, jsonEncode(user.toJson()));
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSignedOut() {
    _user = null;
    _status = SessionStatus.signedOut;
    _errorMessage = null;
    notifyListeners();
  }
}
