import 'package:flutter/material.dart';

import '../../controllers/controllers_scope.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';

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
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  double _passwordStrength = 0;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = _calculateStrength(value);
    });
  }

  double _calculateStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    final lengthScore = (password.length / 12).clamp(0, 1);
    strength += lengthScore * 0.4;
    if (RegExp('[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp('[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp('[!@#%^&*()]').hasMatch(password)) strength += 0.2;
    return strength.clamp(0, 1);
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
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: t.translate('password'),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                onChanged: _onPasswordChanged,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return t.translate('passwordTooShort');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: _passwordStrength == 0 ? null : _passwordStrength,
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _passwordStrength > 0.7
                        ? Colors.green
                        : _passwordStrength > 0.4
                            ? Colors.orange
                            : Colors.redAccent,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: t.translate('confirmPassword'),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.translate('fieldRequired');
                  }
                  if (value != _passwordController.text) {
                    return t.translate('passwordsDoNotMatch');
                  }
                  return null;
                },
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
