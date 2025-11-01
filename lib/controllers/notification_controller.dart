import 'package:flutter/foundation.dart';

import '../models/offer.dart';

class NotificationController extends ChangeNotifier {
  final List<Offer> _list = [];

  List<Offer> get list => List.unmodifiable(_list);

  void pushMockOffer(Offer offer) {
    _list.add(offer);
    notifyListeners();
  }

  void markRead(String id) {
    _list.removeWhere((offer) => offer.id == id);
    notifyListeners();
  }
}
