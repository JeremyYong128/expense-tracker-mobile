import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = true;

  List<Category> get categories => _categories;
  List<Category> get activeCategories => _categories.where((c) => c.isActive).toList();
  List<Category> get activeExpenseCategories => _categories.where((c) => c.isActive && c.isExpense).toList();
  List<Category> get activeIncomeCategories => _categories.where((c) => c.isActive && c.isIncome).toList();
  bool get isLoading => _isLoading;

  List<Category> get incomeCategories => _categories.where((c) => c.isIncome).toList();
  List<Category> get expenseCategories => _categories.where((c) => c.isExpense).toList();

  Category? getCategoryById(int? id) {
    if (id == null) return null;
    return _categories.where((c) => c.id == id).firstOrNull;
  }

  List<Category> getAvailableCategoriesForDropdown(int? currentCategoryId) {
    return _categories.where((c) {
      return c.isActive || c.id == currentCategoryId;
    }).toList();
  }

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    _categories = await DataService.getCategories();
    _isLoading = false;
    notifyListeners();
  }

  Future<int> addCategory(Category category) async {
    final id = await DataService.addCategory(category);
    await fetchCategories();
    return id;
  }

  Future<int> updateCategory(Category category) async {
    final id = await DataService.updateCategory(category);
    await fetchCategories();
    return id;
  }

  Future<void> deleteCategory(int id) async {
    await DataService.deleteCategory(id);
    await fetchCategories();
  }
}
