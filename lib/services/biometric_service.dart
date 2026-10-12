import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import '../core/network/token_storage.dart';

/// The authentication method to surface on the login button, resolved from the
/// device's enrolled biometrics.
enum BiometricMethod { face, fingerprint, pin }

/// Result of a device authentication attempt. A plain `false` can't tell a
/// user cancel apart from the device refusing (no screen lock, locked out after
/// too many attempts) — those need different UI, so the reason is carried out.
class BiometricResult {
  const BiometricResult._(this.success, {this.cancelled = false, this.message});

  final bool success;

  /// The user dismissed the prompt (or the OS already showed its own feedback
  /// for a bad scan). The UI should stay silent.
  final bool cancelled;

  /// User-facing explanation when [success] is false and it wasn't a cancel.
  final String? message;

  static const BiometricResult ok = BiometricResult._(true);
  static const BiometricResult userCancelled =
      BiometricResult._(false, cancelled: true);

  factory BiometricResult.failure(String message) =>
      BiometricResult._(false, message: message);
}

/// Wraps device biometric / passcode authentication (Face ID, Touch ID,
/// fingerprint, or the device PIN/pattern) and persists whether the user has
/// opted in to biometric login.
///
/// The feature works as an *unlock gate* over the already-persisted session:
/// no password is ever stored. When enabled, a successful biometric check on
/// launch restores the saved session instead of requiring the password again.
class BiometricService {
  final LocalAuthentication _auth;
  final TokenStorage tokenStorage;

  BiometricService({
    required this.tokenStorage,
    LocalAuthentication? auth,
  }) : _auth = auth ?? LocalAuthentication();

  /// Whether the device can authenticate the user right now. Uses
  /// [isDeviceSupported] alone — it is true only when a PIN, pattern, password,
  /// or biometric is actually enrolled, unlike `canCheckBiometrics` which is
  /// true merely because a sensor exists.
  Future<bool> canAuthenticate() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Resolves which method to present:
  ///   - Face ID → [BiometricMethod.face]
  ///   - Touch ID / Android fingerprint → [BiometricMethod.fingerprint]
  ///   - anything else (device passcode only) → [BiometricMethod.pin]
  Future<BiometricMethod> resolveMethod() async {
    List<BiometricType> types;
    try {
      types = await _auth.getAvailableBiometrics();
    } catch (_) {
      types = const [];
    }
    if (types.contains(BiometricType.face)) return BiometricMethod.face;
    if (types.contains(BiometricType.fingerprint)) {
      return BiometricMethod.fingerprint;
    }
    // Newer Android reports generic strong/weak instead of a concrete sensor.
    if (types.contains(BiometricType.strong) ||
        types.contains(BiometricType.weak)) {
      return Platform.isIOS
          ? BiometricMethod.face
          : BiometricMethod.fingerprint;
    }
    return BiometricMethod.pin;
  }

  /// Short label for a method, named the way the OS names it so the button
  /// matches the system prompt that follows (Touch ID / Passcode on iOS).
  String labelFor(BiometricMethod method) {
    if (Platform.isIOS) {
      return switch (method) {
        BiometricMethod.face => 'Face ID',
        BiometricMethod.fingerprint => 'Touch ID',
        BiometricMethod.pin => 'Passcode',
      };
    }
    return switch (method) {
      BiometricMethod.face => 'Face Unlock',
      BiometricMethod.fingerprint => 'Fingerprint',
      BiometricMethod.pin => 'PIN',
    };
  }

  /// A user-facing label for the primary method on this device.
  Future<String> primaryLabel() async => labelFor(await resolveMethod());

  /// What the user has to set up when the device can't authenticate at all.
  static String get screenLockSetupMessage => Platform.isIOS
      ? 'Set up a passcode or Face ID / Touch ID in your iPhone Settings first.'
      : 'Set up a screen lock on your phone first — a PIN, pattern, password, '
          'or fingerprint in your device settings.';

  static String get _credentialName =>
      Platform.isIOS ? 'passcode' : 'PIN, pattern, or password';

  /// Prompts the OS authentication dialog. [biometricOnly] false lets the user
  /// fall back to the device PIN/passcode.
  Future<BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      // `false` without an exception = user cancelled or the sensor rejected
      // them; the OS already showed its own feedback.
      return ok ? BiometricResult.ok : BiometricResult.userCancelled;
    } on PlatformException catch (e) {
      debugPrint('local_auth failed (biometricOnly: $biometricOnly): '
          '${e.code} — ${e.message}');
      // Asked for biometrics but none are enrolled (Android only reports this
      // here): retry allowing the device passcode rather than dead-ending.
      final noBiometrics = e.code == auth_error.notEnrolled ||
          e.code == auth_error.notAvailable ||
          e.code == auth_error.biometricOnlyNotSupported;
      if (biometricOnly && noBiometrics) {
        return authenticate(reason: reason, biometricOnly: false);
      }
      return BiometricResult.failure(_messageForCode(e.code));
    } catch (e) {
      debugPrint('local_auth failed: $e');
      return BiometricResult.failure(
        'Device authentication is unavailable. Sign in with your password.',
      );
    }
  }

  static String _messageForCode(String code) {
    switch (code) {
      case auth_error.notEnrolled:
      case auth_error.passcodeNotSet:
        return screenLockSetupMessage;
      case auth_error.lockedOut:
        return 'Too many failed attempts. Wait a moment, then try again or '
            'use your password.';
      case auth_error.permanentlyLockedOut:
        return 'Unlock your device with your $_credentialName first, then try '
            'again.';
      default:
        return "This device can't authenticate you right now. Sign in with "
            'your password.';
    }
  }

  Future<bool> isEnabled() => tokenStorage.isBiometricEnabled();

  Future<void> setEnabled(bool value) =>
      tokenStorage.setBiometricEnabled(value);
}
