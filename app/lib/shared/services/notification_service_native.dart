/// Native implementation for local notifications (Android/iOS).
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification channel IDs
const String _workoutChannelId = 'liftiq_workout';
const String _timerChannelId = 'liftiq_timer';

/// Notification IDs
const int _workoutNotificationId = 1;
const int _restTimerNotificationId = 2;

class NotificationServicePlatform {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _createAndroidChannels();
    }

    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
  }

  Future<void> _createAndroidChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _workoutChannelId,
        'Workout Progress',
        description: 'Shows workout progress and elapsed time',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _timerChannelId,
        'Rest Timer',
        description: 'Rest timer countdown and completion alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final darwinPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (darwinPlugin != null) {
        final granted = await darwinPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final granted =
            await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    }

    return true;
  }

  Future<void> showWorkoutInProgress({
    required String exerciseName,
    required int setCount,
    required int elapsedMinutes,
    int totalExercises = 0,
    int currentExerciseIndex = 0,
  }) async {
    if (!_isInitialized) await initialize();

    final progress = totalExercises > 0
        ? 'Exercise ${currentExerciseIndex + 1}/$totalExercises'
        : '';

    final body = progress.isNotEmpty
        ? '$progress | $setCount sets completed'
        : '$setCount sets completed';

    final pulseIndicator = (elapsedMinutes % 2 == 0) ? '💪' : '🏋️';

    await _notifications.show(
      _workoutNotificationId,
      '$pulseIndicator Workout in Progress - ${_formatDuration(elapsedMinutes)}',
      'Current: $exerciseName | $body',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _workoutChannelId,
          'Workout Progress',
          channelDescription: 'Shows workout progress',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          category: AndroidNotificationCategory.workout,
          colorized: true,
          color: const Color(0xFF6366F1),
          actions: const [
            AndroidNotificationAction(
              'pause',
              'Pause',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'finish',
              'Finish',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: true,
          presentSound: false,
        ),
      ),
    );
  }

  Future<void> showRestTimer({
    required int secondsRemaining,
    bool isComplete = false,
  }) async {
    if (!_isInitialized) await initialize();

    if (isComplete) {
      await _notifications.show(
        _restTimerNotificationId,
        '🔔 Rest Complete!',
        'Time to start your next set',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _timerChannelId,
            'Rest Timer',
            channelDescription: 'Rest timer alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            autoCancel: true,
            category: AndroidNotificationCategory.alarm,
            colorized: true,
            color: Color(0xFF4CAF50),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } else {
      final minutes = secondsRemaining ~/ 60;
      final seconds = secondsRemaining % 60;
      final timeStr = minutes > 0
          ? '$minutes:${seconds.toString().padLeft(2, '0')}'
          : '${seconds}s';

      final pulseIndicator = secondsRemaining.isEven ? '⏱️' : '⏳';
      final urgencyMessage = _getUrgencyMessage(secondsRemaining);
      final notificationColor = _getTimerColor(secondsRemaining);
      final progressPercent =
          100 - ((secondsRemaining / 180) * 100).round().clamp(0, 100);

      await _notifications.show(
        _restTimerNotificationId,
        '$pulseIndicator Rest Timer: $timeStr',
        urgencyMessage,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _timerChannelId,
            'Rest Timer',
            channelDescription: 'Rest timer countdown',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            showWhen: false,
            progress: progressPercent,
            maxProgress: 100,
            showProgress: true,
            category: AndroidNotificationCategory.progress,
            colorized: true,
            color: notificationColor,
            enableLights: true,
            ledColor: notificationColor,
            ledOnMs: 500,
            ledOffMs: 500,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
      );
    }
  }

  String _getUrgencyMessage(int secondsRemaining) {
    if (secondsRemaining <= 10) {
      return 'Get ready! Almost time for your next set';
    } else if (secondsRemaining <= 30) {
      return 'Prepare for your next set soon';
    } else {
      return 'Rest and recover before your next set';
    }
  }

  Color _getTimerColor(int secondsRemaining) {
    if (secondsRemaining <= 10) {
      return const Color(0xFFFF9800);
    } else if (secondsRemaining <= 30) {
      return const Color(0xFFFFEB3B);
    } else {
      return const Color(0xFF2196F3);
    }
  }

  Future<void> showWorkoutComplete({
    required int totalSets,
    required int totalExercises,
    required int durationMinutes,
    double? totalVolume,
  }) async {
    if (!_isInitialized) await initialize();

    final volumeStr = totalVolume != null
        ? ' | ${totalVolume.toStringAsFixed(0)} kg volume'
        : '';

    await _notifications.show(
      _workoutNotificationId,
      'Workout Complete!',
      '$totalExercises exercises, $totalSets sets in ${_formatDuration(durationMinutes)}$volumeStr',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _workoutChannelId,
          'Workout Progress',
          channelDescription: 'Workout completion',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
          category: AndroidNotificationCategory.social,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelWorkoutNotification() async {
    await _notifications.cancel(_workoutNotificationId);
  }

  Future<void> cancelRestTimerNotification() async {
    await _notifications.cancel(_restTimerNotificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
        'NotificationService: Notification tapped: ${response.id}, action: ${response.actionId}');
  }
}
