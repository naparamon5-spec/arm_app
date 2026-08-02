import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../core/network/token_storage.dart';

/// The authentication method to surface on the login button, resolved from the
/// device's enrolled biometrics.
enum BiometricMethod { face, fingerprint, pin }

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

  /// Short label for a method: Face ID / Fingerprint / Pin Code.
  String labelFor(BiometricMethod method) => switch (method) {
        BiometricMethod.face => 'Face ID',
        BiometricMethod.fingerprint => 'Fingerprint',
        BiometricMethod.pin => 'Pin Code',
      };

  /// A user-facing label for the primary method on this device.
  Future<String> primaryLabel() async => labelFor(await resolveMethod());

  /// Prompts the OS authentication dialog. [biometricOnly] false lets the user
  /// fall back to the device PIN/passcode when biometrics aren't set/enrolled.
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      // Asked for biometrics on a device with none enrolled → retry allowing
      // the device passcode rather than dead-ending.
      if (biometricOnly) {
        return authenticate(reason: reason, biometricOnly: false);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() => tokenStorage.isBiometricEnabled();

  Future<void> setEnabled(bool value) =>
      tokenStorage.setBiometricEnabled(value);
}
