import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/credit_card.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';

class CreditCardProvider extends ChangeNotifier {
  List<CreditCard> _creditCards = [];
  bool _isLoading = true;

  List<CreditCard> get creditCards => _creditCards;
  bool get isLoading => _isLoading;

  CreditCardProvider() {
    fetchCreditCards();
  }

  Future<void> fetchCreditCards() async {
    _creditCards = await DataService.getCreditCards();
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addCreditCard(CreditCard card) async {
    final id = await DataService.addCreditCard(card);
    await fetchCreditCards();
    return id;
  }

  Future<void> updateCreditCard(CreditCard card) async {
    await DataService.updateCreditCard(card);
    await fetchCreditCards();
  }

  Future<void> deleteCreditCard(int id) async {
    await DataService.deleteCreditCard(id);
    await fetchCreditCards();
  }
}
