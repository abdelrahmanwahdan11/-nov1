import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import 'package:jewelx/core/i18n/app_localizations.dart';
import 'package:jewelx/core/theme/app_theme.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _noteController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ControllersScope.of(context);
    final checkout = scope.checkoutController;
    final cart = scope.cartController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();

    if (_nameController.text.isEmpty && checkout.contact['name'] != null) {
      _nameController.text = checkout.contact['name']!;
    }
    if (_phoneController.text.isEmpty && checkout.contact['phone'] != null) {
      _phoneController.text = checkout.contact['phone']!;
    }
    if (_cityController.text.isEmpty && checkout.address['city'] != null) {
      _cityController.text = checkout.address['city']!;
    }
    if (_streetController.text.isEmpty && checkout.address['street'] != null) {
      _streetController.text = checkout.address['street']!;
    }
    if (_noteController.text.isEmpty && checkout.notes.isNotEmpty) {
      _noteController.text = checkout.notes;
    }

    final steps = [
      Step(
        title: Text(localization.translate('addressStep')),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        content: Form(
          key: _addressFormKey,
          child: Column(
            children: [
              _CheckoutField(
                controller: _nameController,
                label: localization.translate('fullName'),
                validator: (value) =>
                    value == null || value.isEmpty ? localization.translate('fieldRequired') : null,
              ),
              _CheckoutField(
                controller: _phoneController,
                label: localization.translate('phone'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? localization.translate('fieldRequired') : null,
              ),
              _CheckoutField(
                controller: _cityController,
                label: localization.translate('city'),
                validator: (value) =>
                    value == null || value.isEmpty ? localization.translate('fieldRequired') : null,
              ),
              _CheckoutField(
                controller: _streetController,
                label: localization.translate('street'),
                validator: (value) =>
                    value == null || value.isEmpty ? localization.translate('fieldRequired') : null,
              ),
              _CheckoutField(
                controller: _noteController,
                label: localization.translate('note'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      Step(
        title: Text(localization.translate('reviewStep')),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localization.translate('reviewItems'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            for (final entry in cart.items)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
                  boxShadow: tokens?.softShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.item.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            '${localization.translate('currencySymbol')}${entry.item.price?.toStringAsFixed(2) ?? '0.00'}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Text('x${entry.quantity}', style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            _SummaryLine(
              label: localization.translate('subtotal'),
              value: cart.subtotal,
            ),
            _SummaryLine(
              label: localization.translate('discount'),
              value: cart.discount,
            ),
            _SummaryLine(
              label: localization.translate('shipping'),
              value: cart.shipping,
            ),
            const Divider(),
            _SummaryLine(
              label: localization.translate('total'),
              value: cart.total,
              isBold: true,
            ),
          ],
        ),
      ),
      Step(
        title: Text(localization.translate('confirmStep')),
        isActive: _currentStep >= 2,
        state: _currentStep == 2 ? StepState.indexed : StepState.complete,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localization.translate('confirmDetails'),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('${localization.translate('fullName')}: ${_nameController.text}'),
            Text('${localization.translate('phone')}: ${_phoneController.text}'),
            Text('${localization.translate('city')}: ${_cityController.text}'),
            Text('${localization.translate('street')}: ${_streetController.text}'),
            if (_noteController.text.isNotEmpty)
              Text('${localization.translate('note')}: ${_noteController.text}'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (cart.items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localization.translate('cartEmpty'))),
                  );
                  return;
                }
                final orderId = await checkout.placeOrderMock();
                cart.clear();
                checkout.saveAddress({});
                checkout.saveContact({});
                checkout.saveNotes('');
                if (!mounted) return;
                Navigator.of(context).pushReplacementNamed(
                  OrderSuccessPage.routeName,
                  arguments: orderId,
                );
              },
              child: Text(localization.translate('placeOrder')),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('checkout')),
      ),
      backgroundColor: Colors.transparent,
      body: Theme(
        data: theme.copyWith(canvasColor: Colors.transparent),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_addressFormKey.currentState?.validate() ?? false) {
                checkout.saveAddress({
                  'city': _cityController.text,
                  'street': _streetController.text,
                });
                checkout.saveContact({
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                });
                checkout.saveNotes(_noteController.text);
                setState(() => _currentStep += 1);
              }
            } else if (_currentStep < steps.length - 1) {
              setState(() => _currentStep += 1);
            }
          },
          onStepCancel: () {
            if (_currentStep == 0) {
              Navigator.of(context).pop();
            } else {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (_currentStep < steps.length - 1)
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: Text(localization.translate('next')),
                  ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: Text(localization.translate('back')),
                  ),
                ],
              ],
            );
          },
          steps: steps,
        ),
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final double value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const Spacer(),
          Text(
            '${localization.translate('currencySymbol')}${value.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
