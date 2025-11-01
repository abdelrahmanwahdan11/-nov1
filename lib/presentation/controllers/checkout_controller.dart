import 'package:flutter/foundation.dart';

class CheckoutController extends ChangeNotifier {
  CheckoutController()
      : _address = const {},
        _contact = const {},
        _notes = '';

  Map<String, String> _address;
  Map<String, String> _contact;
  String _notes;

  Map<String, String> get address => Map.unmodifiable(_address);
  Map<String, String> get contact => Map.unmodifiable(_contact);
  String get notes => _notes;

  void saveAddress(Map<String, String> address) {
    _address = Map.unmodifiable(address);
    notifyListeners();
  }

  void saveContact(Map<String, String> contact) {
    _contact = Map.unmodifiable(contact);
    notifyListeners();
  }

  void saveNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  Future<void> placeOrderMock() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
  }
}
