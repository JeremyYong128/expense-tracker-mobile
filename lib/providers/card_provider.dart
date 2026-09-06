import 'package:flutter/material.dart' hide Card;
import 'package:expense_tracker_mobile/models/card.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';

class CardProvider extends ChangeNotifier {
  List<Card> _cards = [];
  bool _isLoading = true;

  List<Card> get cards => _cards;
  bool get isLoading => _isLoading;

  CardProvider() {
    fetchCards();
  }

  Future<void> fetchCards() async {
    _cards = await DataService.getCards();
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addCard(Card card) async {
    final id = await DataService.addCard(card);
    await fetchCards();
    return id;
  }

  Future<void> updateCard(Card card) async {
    await DataService.updateCard(card);
    await fetchCards();
  }

  Future<bool> deleteCard(int id, {bool forceHardDelete = false}) async {
    final affected = await DataService.deleteCard(
      id,
      forceHardDelete: forceHardDelete,
    );
    await fetchCards();
    return affected;
  }
}
