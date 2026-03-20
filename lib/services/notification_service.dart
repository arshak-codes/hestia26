import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> initialize({
    required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  }) async {
    if (_initialized) {
      return;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _messaging.subscribeToTopic('event_updates');

    final token = await _messaging.getToken();
    debugPrint('FCM token: $token');

    FirebaseMessaging.onMessage.listen((message) {
      _showForegroundMessage(scaffoldMessengerKey, message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_logOpenedMessage);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _logOpenedMessage(initialMessage);
    }

    _initialized = true;
  }

  void _showForegroundMessage(
    GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
    RemoteMessage message,
  ) {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      debugPrint('Foreground message skipped: ScaffoldMessenger not ready');
      return;
    }

    final title = notification.title ?? 'Hestia Update';
    final body = notification.body ?? '';

    messenger
      ..clearMaterialBanners()
      ..showMaterialBanner(
        MaterialBanner(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          dividerColor: Colors.transparent,
          overflowAlignment: OverflowBarAlignment.end,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          leadingPadding: EdgeInsets.zero,
          content: _TopNotificationBanner(
            title: title,
            body: body,
            onDismissed: messenger.clearMaterialBanners,
          ),
          actions: const [SizedBox.shrink()],
        ),
      );

    Future<void>.delayed(const Duration(seconds: 4), () {
      messenger.clearMaterialBanners();
    });
  }

  void _logOpenedMessage(RemoteMessage message) {
    debugPrint('Notification opened: ${message.messageId}');
  }
}

class _TopNotificationBanner extends StatelessWidget {
  const _TopNotificationBanner({
    required this.title,
    required this.body,
    required this.onDismissed,
  });

  final String title;
  final String body;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('$title-$body'),
      direction: DismissDirection.up,
      onDismissed: (_) => onDismissed(),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24, width: 1.1),
            gradient: const LinearGradient(
              colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.4),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111114),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [Colors.white, Color(0xFFE28B9B)],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'EVENT UPDATE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                letterSpacing: 1.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (body.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDismissed,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white54,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
