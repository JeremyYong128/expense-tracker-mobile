import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/models/category.dart';

class CategoryAppearance {
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

  static const List<String> colorHexes = [
    '#9E9E9E', // Grey (Default)
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#795548', // Brown
    '#607D8B', // Blue Grey
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

  static Color getColorFromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.grey;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension CategoryAppearanceExt on Category {
  IconData get iconData => CategoryAppearance.getIconData(iconString);
  Color get color => CategoryAppearance.getColorFromHex(colorHex);
}
