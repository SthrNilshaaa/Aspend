import 'dart:async';
import 'package:flutter/services.dart';

import 'transaction_detection_service.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('transaction_detection');

  static final StreamController<String> _uiEventController =
      StreamController<String>.broadcast();
  static Stream<String> get uiEvents => _uiEventController.stream;

  static String? _pendingEvent;

  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static String? consumePendingEvent() {
    final event = _pendingEvent;
    _pendingEvent = null;
    return event;
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationReceived':
        final text = call.arguments['text'] as String? ?? '';
        final packageName = call.arguments['packageName'] as String? ?? '';

        await TransactionDetectionService.processNotification('', text,
            packageName: packageName);
        break;

      case 'onSmsReceived':
        final body = call.arguments['body'] as String? ?? '';
        final sender = call.arguments['sender'] as String? ?? '';
        await TransactionDetectionService.processSmsMessage(body,
            sender: sender);
        break;

      case 'showAddIncomeDialog':
        _emitEvent('SHOW_ADD_INCOME');
        break;

      case 'showAddExpenseDialog':
        _emitEvent('SHOW_ADD_EXPENSE');
        break;

      default:
        print('Unknown method call: ${call.method}');
    }
  }

  static void _emitEvent(String event) {
    if (!_uiEventController.hasListener) {
      _pendingEvent = event;
    }
    _uiEventController.add(event);
  }

  static void notifyTransactionDetected() {
    _emitEvent('RELOAD_TRANSACTIONS');
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      final result =
          await _channel.invokeMethod('requestNotificationPermission');
      return result as bool? ?? false;
    } catch (e) {
      print('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<bool> checkNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod('checkNotificationPermission');
      return result as bool? ?? false;
    } catch (e) {
      print('Error checking notification permission: $e');
      return false;
    }
  }

  static Future<bool> requestBatteryOptimization() async {
    try {
      final result = await _channel.invokeMethod('requestBatteryOptimization');
      return result as bool? ?? false;
    } catch (e) {
      print('Error requesting battery optimization: $e');
      return false;
    }
  }

  static Future<bool> startKeepAliveService() async {
    try {
      final result = await _channel.invokeMethod('startKeepAliveService');
      return result as bool? ?? false;
    } catch (e) {
      print('Error starting keep alive service: $e');
      return false;
    }
  }

  static Future<List<String>> getPendingNotifications() async {
    try {
      final List<dynamic>? result =
          await _channel.invokeMethod('getPendingNotifications');
      return result?.map((e) => e as String).toList() ?? [];
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  static Future<bool> stopKeepAliveService() async {
    try {
      final result = await _channel.invokeMethod('stopKeepAliveService');
      return result as bool? ?? false;
    } catch (e) {
      print('Error stopping keep alive service: $e');
      return false;
    }
  }
}
