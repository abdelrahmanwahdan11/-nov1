import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../controllers/notification_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllersScope.of(context).notificationController;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final list = controller.list;
        if (list.isEmpty) {
          return const Center(child: Text('No notifications yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final offer = list[index];
            return Card(
              child: ListTile(
                title: Text('Offer from ${offer.from}'),
                subtitle: Text('Amount: ${offer.amount.toStringAsFixed(0)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => controller.markRead(offer.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
