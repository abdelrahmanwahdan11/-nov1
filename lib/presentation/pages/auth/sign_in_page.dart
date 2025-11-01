import 'package:flutter/material.dart';

import '../../controllers/controllers_scope.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  static const routeName = '/auth/signin';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = ControllersScope.of(context).authController;
    return Scaffold(
      appBar: AppBar(title: Text(t.translate('signIn'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: t.translate('email')),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.translate('email');
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: t.translate('password'),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Min 6 chars';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() {
                          _loading = true;
                          _error = null;
                        });
                        final success = await auth.signIn(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (!mounted) return;
                        if (success) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else {
                          setState(() {
                            _loading = false;
                            _error = 'Unable to sign in';
                          });
                        }
                      },
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.translate('signIn')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await auth.signInGuest();
                  if (!mounted) return;
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: Text(t.translate('guest')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/auth/forgot'),
                child: Text(t.translate('forgotPassword')),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/auth/signup'),
                child: Text(t.translate('signUp')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
