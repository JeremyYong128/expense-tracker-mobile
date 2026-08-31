import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';

class Category {
  final int? id;
  final String name;
  final String colorHex;
  final String? iconString;
  final bool isActive;
  final bool isExpense;
  final bool isIncome;

  Category({
    this.id,
    required this.name,
    required this.colorHex,
    this.iconString,
    this.isActive = true,
    this.isExpense = true,
    this.isIncome = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'iconString': iconString,
      'isActive': isActive ? 1 : 0,
      'isExpense': isExpense ? 1 : 0,
      'isIncome': isIncome ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorHex: map['colorHex'] ?? '#9E9E9E',
      iconString: map['iconString'],
      isActive: map['isActive'] == null ? true : map['isActive'] == 1,
      isExpense: map['isExpense'] == null ? true : map['isExpense'] == 1,
      isIncome: map['isIncome'] == null ? false : map['isIncome'] == 1,
    );
  }

  static const List<String> iconNames = [
    'category',
    'shopping_cart',
    'fastfood',
    'restaurant',
    'local_cafe',
    'directions_car',
    'train',
    'flight',
    'home',
    'receipt',
    'movie',
    'favorite',
    'health_and_safety',
    'fitness_center',
    'local_hospital',
    'school',
    'work',
    'monetization_on',
    'pets',
    'spa',
    'local_mall',
    'redeem',
  ];

  static IconData getIconData(String? iconString) {
    if (iconString == null) return Icons.category;
    
    final lower = iconString.toLowerCase();
    switch (lower) {
      case 'shopping_cart':
      case 'shopping':
      case 'groceries':
        return Icons.shopping_cart;
      case 'fastfood':
      case 'food':
      case 'dining':
        return Icons.fastfood;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'directions_car':
      case 'transport':
      case 'transit':
        return Icons.directions_car;
      case 'train':
        return Icons.train;
      case 'flight':
        return Icons.flight;
      case 'home':
        return Icons.home;
      case 'receipt':
      case 'bills':
      case 'utilities':
        return Icons.receipt;
      case 'movie':
      case 'entertainment':
        return Icons.movie;
      case 'favorite':
      case 'health':
        return Icons.favorite;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'monetization_on':
      case 'salary':
      case 'income':
        return Icons.monetization_on;
      case 'pets':
        return Icons.pets;
      case 'spa':
        return Icons.spa;
      case 'local_mall':
        return Icons.local_mall;
      case 'redeem':
        return Icons.redeem;
      default:
        return Icons.category;
    }
  }

  IconData get iconData => getIconData(iconString);
  Color get color => AppColors.getColorFromHex(colorHex);
}
