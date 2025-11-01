import 'package:flutter/material.dart';

import '../../controllers/controllers_scope.dart';
import '../../l10n/app_localizations.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const routeName = '/auth/signup';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = ControllersScope.of(context).authController;
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('signUp'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(labelText: t.translate('profile')),
                validator: (value) =>
                    value != null && value.length >= 2 ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: t.translate('email')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value != null && value.contains('@') ? null : 'Invalid',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: t.translate('password')),
                validator: (value) =>
                    value != null && value.length >= 6 ? null : 'Min 6 chars',
              ),
              const Spacer(),
              FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _loading = true);
                        final result = await auth.signUp(
                          displayName: _displayNameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        if (!mounted) return;
                        setState(() => _loading = false);
                        if (result) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.translate('signUp')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed('/auth/signin'),
                child: Text(t.translate('signIn')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
