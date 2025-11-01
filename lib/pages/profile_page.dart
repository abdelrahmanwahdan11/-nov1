import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = ControllersScope.of(context).authController;
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        final user = auth.currentUser;
        if (user == null) {
          return const Center(child: Text('Guest'));
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 36, child: Text(user.displayName.characters.first)),
              const SizedBox(height: 16),
              Text(user.displayName, style: Theme.of(context).textTheme.titleLarge),
              Text(user.email),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => auth.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        );
      },
    );
  }
}
