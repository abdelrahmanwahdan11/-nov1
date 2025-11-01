import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/cart_entry.dart';
import '../theme/app_theme.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _couponController = TextEditingController();
  String? _couponStatus;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = ControllersScope.of(context);
    final cart = scope.cartController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final items = cart.items;
        Widget body;
        if (items.isEmpty) {
          body = Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    localization.translate('cartEmpty'),
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/catalog/jewelry'),
                    child: Text(localization.translate('goShopping')),
                  ),
                ],
              ),
            ),
          );
        } else {
          body = Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CartTile(
                        entry: entry,
                        tokens: tokens,
                        localization: localization,
                        onIncrement: () => cart.setQty(entry.item.id, entry.quantity + 1),
                        onDecrement: () => cart.setQty(entry.item.id, entry.quantity - 1),
                        onRemove: () => cart.remove(entry.item.id),
                      ),
                    );
                  },
                ),
              ),
              _CartSummary(
                tokens: tokens,
                localization: localization,
                subtotal: cart.subtotal,
                discount: cart.discount,
                shipping: cart.shipping,
                total: cart.total,
                couponController: _couponController,
                couponStatus: _couponStatus,
                onApplyCoupon: () {
                  final code = _couponController.text.trim();
                  cart.applyCoupon(code);
                  setState(() {
                    if (code.isEmpty) {
                      _couponStatus = localization.translate('couponCleared');
                    } else if (cart.discount > 0) {
                      _couponStatus = localization.translate('couponApplied');
                    } else {
                      _couponStatus = localization.translate('invalidCoupon');
                    }
                  });
                },
                onCheckout: () => Navigator.of(context).pushNamed('/checkout'),
                onClear: () {
                  cart.clear();
                  setState(() => _couponStatus = null);
                },
              ),
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(localization.translate('cart'))),
          backgroundColor: Colors.transparent,
          body: SafeArea(child: body),
        );
      },
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({
    required this.entry,
    required this.tokens,
    required this.localization,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartEntry entry;
  final JewelThemeTokens? tokens;
  final AppLocalizations localization;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceText = entry.item.price != null
        ? '${localization.translate('currencySymbol')}${entry.item.price!.toStringAsFixed(2)}'
        : localization.translate('priceOnRequest');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.82),
        borderRadius: BorderRadius.circular(tokens?.cardRadius ?? 26),
        boxShadow: tokens?.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular((tokens?.cardRadius ?? 26) - 4),
            child: Image.network(
              entry.item.images.isNotEmpty
                  ? entry.item.images.first
                  : 'https://picsum.photos/seed/cart/200/200',
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(priceText, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: onDecrement),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('${entry.quantity}', style: theme.textTheme.titleMedium),
                      ),
                      _QtyButton(icon: Icons.add, onTap: onIncrement),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline),
                        label: Text(localization.translate('remove')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.primary),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.tokens,
    required this.localization,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.couponController,
    required this.couponStatus,
    required this.onApplyCoupon,
    required this.onCheckout,
    required this.onClear,
  });

  final JewelThemeTokens? tokens;
  final AppLocalizations localization;
  final double subtotal;
  final double discount;
  final double shipping;
  final double total;
  final TextEditingController couponController;
  final String? couponStatus;
  final VoidCallback onApplyCoupon;
  final VoidCallback onCheckout;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens?.cardRadius ?? 26),
        ),
        boxShadow: tokens?.softShadow,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponController,
                  decoration: InputDecoration(
                    labelText: localization.translate('applyCoupon'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onApplyCoupon,
                style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
                child: Text(localization.translate('apply')),
              ),
            ],
          ),
          if (couponStatus != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                couponStatus!,
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _SummaryRow(
            localization: localization,
            label: localization.translate('subtotal'),
            value: subtotal,
          ),
          _SummaryRow(
            localization: localization,
            label: localization.translate('discount'),
            value: -discount,
            valueColor: discount > 0 ? theme.colorScheme.primary : null,
          ),
          _SummaryRow(
            localization: localization,
            label: localization.translate('shipping'),
            value: shipping,
          ),
          const Divider(height: 32),
          _SummaryRow(
            localization: localization,
            label: localization.translate('total'),
            value: total,
            isBold: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  child: Text(localization.translate('clearCart')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onCheckout,
                  child: Text(localization.translate('checkout')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.localization,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final AppLocalizations localization;
  final String label;
  final double value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '${localization.translate('currencySymbol')}${value.toStringAsFixed(2)}',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
