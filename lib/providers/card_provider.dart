import 'package:flutter/material.dart' hide Card;
import 'package:expense_tracker_mobile/models/card.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';

class CardProvider extends ChangeNotifier {
  List<Card> _cards = [];
  bool _isLoading = true;

  List<Card> get cards => _cards;
  bool get isLoading => _isLoading;

  List<Card> get activeCards => _cards.where((c) => c.isActive).toList();
  List<Card> get archivedCards => _cards.where((c) => !c.isActive).toList();

  Card? getCardById(int? id) {
    if (id == null) return null;
    return _cards.where((c) => c.id == id).firstOrNull;
  }

  List<Card> getAvailableCardsForDropdown(int? currentCardId) {
    return _cards.where((c) {
      return c.isActive || c.id == currentCardId;
    }).toList();
  }

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

  void reorderCard(int oldIndex, int newIndex) {
    List<Card> subset = List.from(activeCards);

    final globalIndices = subset.map((c) => _cards.indexOf(c)).toList();
    
    final item = subset.removeAt(oldIndex);
    subset.insert(newIndex, item);

    for (int i = 0; i < globalIndices.length; i++) {
      final idx = globalIndices[i];
      if (idx != -1) {
        _cards[idx] = subset[i];
      }
    }

    for (int i = 0; i < _cards.length; i++) {
      _cards[i] = _cards[i].copyWith(sortOrder: i);
    }
    notifyListeners();
    DataService.updateCardsOrder(_cards);
  }
}
