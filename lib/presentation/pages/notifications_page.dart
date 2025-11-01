import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/notification_controller.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/domain/models/app_notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationType? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = ControllersScope.of(context).notificationController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('notifications')),
        actions: [
          IconButton(
            tooltip: localization.translate('clearAll'),
            icon: const Icon(Icons.clear_all),
            onPressed: controller.notifications.isEmpty
                ? null
                : () => controller.clearAll(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final notifications = controller.filtered(_filter);
          final preferences = controller.preferences.toMap();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ChoiceChip(
                    label: Text(localization.translate('allNotifications')),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  for (final type in NotificationType.values)
                    ChoiceChip(
                      label: Text(localization.translate(type.key())),
                      selected: _filter == type,
                      onSelected: (_) => setState(() => _filter = type),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(localization.translate('notificationPreferences')),
                  children: [
                    for (final entry in preferences.entries)
                      SwitchListTile(
                        value: entry.value,
                        onChanged: (value) => controller.toggleSubscription(entry.key, value),
                        title: Text(localization.translate(entry.key.key())),
                        subtitle: Text(localization.translate('${entry.key.key()}.description')),
                      ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        localization.translate('noNotifications'),
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...notifications.map(
                  (notification) => _NotificationTile(
                    notification: notification,
                    localization: localization,
                    onMarkRead: () => controller.markRead(notification.id),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.localization,
    required this.onMarkRead,
  });

  final AppNotification notification;
  final AppLocalizations localization;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRead = notification.read;
    final timestamp = notification.timestamp;
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final timeLabel = _formatElapsed(difference, localization);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isRead
          ? theme.colorScheme.surface.withOpacity(0.7)
          : theme.colorScheme.primaryContainer.withOpacity(0.9),
      child: ListTile(
        title: Text(
          notification.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 6),
            Text(
              '${localization.translate(notification.type.key())} · $timeLabel',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(isRead ? Icons.check_circle : Icons.mark_email_read_outlined),
          onPressed: onMarkRead,
        ),
      ),
    );
  }

  String _formatElapsed(Duration diff, AppLocalizations localization) {
    if (diff.inMinutes < 1) {
      return localization.translate('justNow');
    }
    if (diff.inHours < 1) {
      return localization.translate('minutesAgo', args: {'value': diff.inMinutes});
    }
    if (diff.inDays < 1) {
      return localization.translate('hoursAgo', args: {'value': diff.inHours});
    }
    return localization.translate('daysAgo', args: {'value': diff.inDays});
  }
}
