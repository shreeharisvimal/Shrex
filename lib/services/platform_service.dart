import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class PlatformService {
  static const MethodChannel _channel = MethodChannel('shrex/platform');
  static const String _tag = 'PlatformService';

  /// Lock the device for a focus session
  static Future<bool> lockDevice(int durationSeconds) async {
    try {
      debugPrint('$_tag: Attempting to lock device for $durationSeconds seconds');
      final result = await _channel.invokeMethod('lockDevice', {
        'duration': durationSeconds,
      });
      debugPrint('$_tag: Lock device result: $result');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error locking device: $e');
      return false;
    }
  }

  /// Unlock the device
  static Future<bool> unlockDevice() async {
    try {
      debugPrint('$_tag: Attempting to unlock device');
      final result = await _channel.invokeMethod('unlockDevice');
      debugPrint('$_tag: Unlock device result: $result');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error unlocking device: $e');
      return false;
    }
  }

  /// Check if device is currently locked
  static Future<bool> isLockActive() async {
    try {
      final result = await _channel.invokeMethod('isLockActive');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error checking lock status: $e');
      return false;
    }
  }

  /// Check all required permissions
  static Future<Map<String, bool>> checkPermissions() async {
    try {
      final result = await _channel.invokeMethod('checkPermissions');
      return Map<String, bool>.from(result ?? {});
    } catch (e) {
      debugPrint('$_tag: Error checking permissions: $e');
      return {};
    }
  }

  /// Request necessary permissions
  static Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestPermissions');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error requesting permissions: $e');
      return false;
    }
  }

  /// Request device admin permission for robust locking
  static Future<bool> requestDeviceAdminPermission() async {
    try {
      debugPrint('$_tag: Requesting device admin permission');
      final result = await _channel.invokeMethod('requestDeviceAdmin');
      debugPrint('$_tag: Device admin permission request result: $result');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error requesting device admin permission: $e');
      return false;
    }
  }

  /// Check if device admin is enabled
  static Future<bool> isDeviceAdminEnabled() async {
    try {
      final result = await _channel.invokeMethod('isDeviceAdminEnabled');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error checking device admin status: $e');
      return false;
    }
  }

  /// Emergency unlock with password
  static Future<bool> emergencyUnlock(String password) async {
    try {
      debugPrint('$_tag: Attempting emergency unlock');
      final result = await _channel.invokeMethod('emergencyUnlock', {
        'password': password,
      });
      debugPrint('$_tag: Emergency unlock result: $result');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error during emergency unlock: $e');
      return false;
    }
  }

  /// Set emergency password
  static Future<bool> setEmergencyPassword(String password) async {
    try {
      debugPrint('$_tag: Setting emergency password');
      final result = await _channel.invokeMethod('setEmergencyPassword', {
        'password': password,
      });
      debugPrint('$_tag: Set emergency password result: $result');
      return result == true;
    } catch (e) {
      debugPrint('$_tag: Error setting emergency password: $e');
      return false;
    }
  }
}
