import 'package:flutter/material.dart';

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class AppCategories {
  static const List<CategoryData> expense = [
    CategoryData(name: 'Food', icon: Icons.restaurant, color: Color(0xFFFF6B6B)),
    CategoryData(name: 'Transport', icon: Icons.directions_car, color: Color(0xFF4ECDC4)),
    CategoryData(name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFFFFE66D)),
    CategoryData(name: 'Bills', icon: Icons.receipt_long, color: Color(0xFF95E1D3)),
    CategoryData(name: 'Entertainment', icon: Icons.movie, color: Color(0xFFDDA0DD)),
    CategoryData(name: 'Health', icon: Icons.local_hospital, color: Color(0xFFFF8A5C)),
    CategoryData(name: 'Education', icon: Icons.school, color: Color(0xFF6C5CE7)),
    CategoryData(name: 'Rent', icon: Icons.home, color: Color(0xFF00B894)),
    CategoryData(name: 'Travel', icon: Icons.flight, color: Color(0xFF0984E3)),
    CategoryData(name: 'Grocery', icon: Icons.local_grocery_store, color: Color(0xFFFDAC53)),
    CategoryData(name: 'Subscriptions', icon: Icons.subscriptions, color: Color(0xFFA29BFE)),
    CategoryData(name: 'Other', icon: Icons.more_horiz, color: Color(0xFF636E72)),
  ];

  static const List<CategoryData> income = [
    CategoryData(name: 'Salary', icon: Icons.account_balance, color: Color(0xFF00B894)),
    CategoryData(name: 'Freelance', icon: Icons.laptop, color: Color(0xFF6C5CE7)),
    CategoryData(name: 'Investment', icon: Icons.trending_up, color: Color(0xFF0984E3)),
    CategoryData(name: 'Gift', icon: Icons.card_giftcard, color: Color(0xFFFD79A8)),
    CategoryData(name: 'Business', icon: Icons.business, color: Color(0xFFFDAC53)),
    CategoryData(name: 'Refund', icon: Icons.replay, color: Color(0xFF4ECDC4)),
    CategoryData(name: 'Other', icon: Icons.more_horiz, color: Color(0xFF636E72)),
  ];

  static const List<String> accountTypes = [
    'Cash Wallet',
    'UPI Wallet',
    'SBI Bank',
    'HDFC Bank',
  ];

  static CategoryData? getCategory(String name, String type) {
    final list = type == 'income' ? income : expense;
    try {
      return list.firstWhere((c) => c.name == name);
    } catch (_) {
      return list.last;
    }
  }
}
