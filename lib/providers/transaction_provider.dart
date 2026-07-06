import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/categories.dart';
import '../services/db_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _budgets = [];
  List<String> _accounts = List<String>.from(AppCategories.accountTypes);
  List<String> _customExpenseCategories = [];
  List<String> _customIncomeCategories = [];
  String _filterType = 'All';
  String _filterCategory = 'All';
  String _searchQuery = '';
  String _dateRange = 'month';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isDarkMode = true;
  String _currency = '₹';
  double _savingsGoal = 0;

  TransactionProvider() {
    loadData();
  }

  List<Map<String, dynamic>> get allTransactions => _transactions;
  List<Map<String, dynamic>> get paymentTransactions =>
      _transactions.where((t) => (t['entryType'] ?? '') == 'payment').toList();
  List<Map<String, dynamic>> get budgets => _budgets;
  List<String> get accounts => List.unmodifiable(_accounts);
  String get filterType => _filterType;
  String get filterCategory => _filterCategory;
  String get searchQuery => _searchQuery;
  String get dateRange => _dateRange;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  bool get isDarkMode => _isDarkMode;
  String get currency => _currency;
  double get savingsGoal => _savingsGoal;
  double get savingsProgress =>
      _savingsGoal > 0 ? (balance / _savingsGoal).clamp(0.0, 1.0) : 0.0;

  List<Map<String, dynamic>> get filteredTransactions {
    var list = List<Map<String, dynamic>>.from(_transactions);
    final now = DateTime.now();

    list = list.where((t) {
      final date = DateTime.tryParse(t['date'] ?? '');
      if (date == null) return false;
      switch (_dateRange) {
        case 'week':
          return now.difference(date).inDays <= 7;
        case 'month':
          return date.month == now.month && date.year == now.year;
        case 'year':
          return date.year == now.year;
        case 'custom':
          if (_customStartDate != null && _customEndDate != null) {
            final dateOnly = DateTime(date.year, date.month, date.day);
            final start = DateTime(_customStartDate!.year,
                _customStartDate!.month, _customStartDate!.day);
            final end = DateTime(_customEndDate!.year, _customEndDate!.month,
                _customEndDate!.day);
            return !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
          }
          if (_customStartDate != null) {
            final dateOnly = DateTime(date.year, date.month, date.day);
            final start = DateTime(_customStartDate!.year,
                _customStartDate!.month, _customStartDate!.day);
            return dateOnly == start;
          }
          return true;
        default:
          return true;
      }
    }).toList();

    if (_filterType != 'All') {
      list = list
          .where((t) =>
              t['type']?.toString().toLowerCase() == _filterType.toLowerCase())
          .toList();
    }

    if (_filterCategory != 'All') {
      list = list.where((t) => t['category'] == _filterCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((t) {
        final title = (t['title'] ?? '').toString().toLowerCase();
        final category = (t['category'] ?? '').toString().toLowerCase();
        final account = (t['account'] ?? '').toString().toLowerCase();
        final paymentMode = (t['paymentMode'] ?? '').toString().toLowerCase();
        final note = (t['note'] ?? '').toString().toLowerCase();
        final party = (t['partyName'] ?? '').toString().toLowerCase();
        final purpose = (t['paymentPurpose'] ?? '').toString().toLowerCase();
        final reference = (t['reference'] ?? '').toString().toLowerCase();
        final entryType = (t['entryType'] ?? '').toString().toLowerCase();
        final paymentDirection =
            (t['paymentDirection'] ?? '').toString().toLowerCase();
        final paymentStatus =
            (t['paymentStatus'] ?? '').toString().toLowerCase();
        final amount = (t['amount'] ?? 0.0).toDouble();
        final amountStr = amount.toStringAsFixed(0);
        final amountStr2 = amount.toStringAsFixed(2);
        final date = DateTime.tryParse(t['date'] ?? '');

        if (title.contains(q) ||
            category.contains(q) ||
            account.contains(q) ||
            note.contains(q) ||
            party.contains(q) ||
            purpose.contains(q) ||
            reference.contains(q) ||
            paymentMode.contains(q) ||
            entryType.contains(q) ||
            paymentDirection.contains(q) ||
            paymentStatus.contains(q)) {
          return true;
        }

        if (amountStr.startsWith(q) ||
            amountStr == q ||
            amountStr2.startsWith(q)) {
          return true;
        }

        if (date != null) {
          final day = date.day.toString();
          final dayPadded = date.day.toString().padLeft(2, '0');
          final monthName = DateFormat('MMMM').format(date).toLowerCase();
          final monthShort = DateFormat('MMM').format(date).toLowerCase();
          final dayName = DateFormat('EEEE').format(date).toLowerCase();

          if (day == q || dayPadded == q) return true;
          if (monthName.startsWith(q) || monthShort.startsWith(q)) {
            return true;
          }
          if (dayName.startsWith(q)) return true;

          final formatted = DateFormat('dd/MM').format(date).toLowerCase();
          if (formatted.contains(q)) return true;

          if (q.length >= 3) {
            final full = DateFormat('MMM dd, yyyy').format(date).toLowerCase();
            if (full.contains(q)) return true;
          }
        }

        return false;
      }).toList();
    }

    list.sort((a, b) {
      final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return list;
  }

  double get totalIncome => _transactions
      .where((t) => t['type'] == 'income')
      .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
  double get totalExpense => _transactions
      .where((t) => t['type'] == 'expense')
      .fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
  double get balance => totalIncome - totalExpense;
  double get thisMonthIncome => _getMonthlyTotal('income');
  double get thisMonthExpense => _getMonthlyTotal('expense');
  double get lastMonthIncome => _getMonthlyTotal('income', monthsAgo: 1);
  double get lastMonthExpense => _getMonthlyTotal('expense', monthsAgo: 1);

  double _getMonthlyTotal(String type, {int monthsAgo = 0}) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month - monthsAgo, 1);
    return _transactions.where((t) {
      final date = DateTime.tryParse(t['date'] ?? '');
      return t['type'] == type &&
          date != null &&
          date.month == target.month &&
          date.year == target.year;
    }).fold(0.0, (sum, t) => sum + (t['amount'] ?? 0.0));
  }

  int get totalTransactionCount => _transactions.length;
  int get thisMonthTransactionCount {
    final now = DateTime.now();
    return _transactions.where((t) {
      final date = DateTime.tryParse(t['date'] ?? '');
      return date != null && date.month == now.month && date.year == now.year;
    }).length;
  }

  Map<String, double> get categoryExpenses {
    final now = DateTime.now();
    Map<String, double> map = {};
    for (var t in _transactions) {
      if (t['type'] == 'expense') {
        final date = DateTime.tryParse(t['date'] ?? '');
        if (date != null && date.month == now.month && date.year == now.year) {
          final cat = t['category'] ?? 'Other';
          map[cat] = (map[cat] ?? 0) + (t['amount'] ?? 0.0);
        }
      }
    }
    return map;
  }

  Map<String, double> get categoryIncome {
    final now = DateTime.now();
    Map<String, double> map = {};
    for (var t in _transactions) {
      if (t['type'] == 'income') {
        final date = DateTime.tryParse(t['date'] ?? '');
        if (date != null && date.month == now.month && date.year == now.year) {
          final cat = t['category'] ?? 'Other';
          map[cat] = (map[cat] ?? 0) + (t['amount'] ?? 0.0);
        }
      }
    }
    return map;
  }

  List<Map<String, double>> get last6MonthsData {
    List<Map<String, double>> result = [];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      double income = 0;
      double expense = 0;

      for (var t in _transactions) {
        final date = DateTime.tryParse(t['date'] ?? '');
        if (date != null &&
            date.month == month.month &&
            date.year == month.year) {
          if (t['type'] == 'income') {
            income += (t['amount'] ?? 0.0);
          } else {
            expense += (t['amount'] ?? 0.0);
          }
        }
      }

      result.add({
        'month': month.month.toDouble(),
        'year': month.year.toDouble(),
        'income': income,
        'expense': expense,
      });
    }

    return result;
  }

  List<Map<String, double>> get dailyExpenses {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    List<Map<String, double>> result = [];

    for (int day = 1; day <= daysInMonth; day++) {
      double total = 0;
      for (var t in _transactions) {
        final date = DateTime.tryParse(t['date'] ?? '');
        if (date != null &&
            date.day == day &&
            date.month == now.month &&
            date.year == now.year &&
            t['type'] == 'expense') {
          total += (t['amount'] ?? 0.0);
        }
      }
      result.add({'day': day.toDouble(), 'amount': total});
    }

    return result;
  }

  double getBudgetForCategory(String category) {
    final now = DateTime.now();
    final monthStr = DateFormat('yyyy-MM').format(now);
    final budget = _budgets
        .where((b) => b['category'] == category && b['month'] == monthStr)
        .toList();
    return budget.isNotEmpty ? (budget.first['limit'] ?? 0.0) : 0.0;
  }

  double getSpentForCategory(String category) {
    return categoryExpenses[category] ?? 0.0;
  }

  double getBudgetProgress(String category) {
    final budget = getBudgetForCategory(category);
    if (budget == 0) return 0;
    final spent = getSpentForCategory(category);
    return (spent / budget).clamp(0.0, 1.5);
  }

  String get topExpenseCategory {
    if (categoryExpenses.isEmpty) return 'N/A';
    return categoryExpenses.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double get avgDailyExpense {
    final now = DateTime.now();
    if (totalExpense == 0) return 0;
    return totalExpense / now.day;
  }

  void loadData() {
    _transactions = DbService.getAllTransactions();
    _budgets = DbService.getAllBudgets();
    _loadAccounts();
    _loadCustomCategories();
    _isDarkMode = DbService.getSetting('isDarkMode', defaultValue: true);
    _currency = DbService.getSetting('currency', defaultValue: '₹');
    _savingsGoal =
        (DbService.getSetting('savingsGoal', defaultValue: 0.0) as num)
            .toDouble();
    notifyListeners();
  }

  Future<void> addTransaction(Map<String, dynamic> data) async {
    data['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    await DbService.addTransaction(data);
    loadData();
  }

  Future<void> updateTransaction(
      int hiveIndex, Map<String, dynamic> data) async {
    await DbService.updateTransaction(hiveIndex, data);
    loadData();
  }

  Future<void> deleteTransaction(int hiveIndex) async {
    await DbService.deleteTransaction(hiveIndex);
    loadData();
  }

  int getHiveIndex(Map<String, dynamic> transaction) {
    final allData = DbService.getAllTransactions();
    return allData.indexWhere((t) => t['id'] == transaction['id']);
  }

  Future<void> saveBudget(String category, double limit) async {
    final now = DateTime.now();
    final monthStr = DateFormat('yyyy-MM').format(now);
    await DbService.saveBudget({
      'category': category,
      'limit': limit,
      'month': monthStr,
    });
    loadData();
  }

  Future<void> clearAllData() async {
    await DbService.transactionBox.clear();
    await DbService.budgetBox.clear();
    loadData();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDateRange(String range) {
    _dateRange = range;
    if (range != 'custom') {
      _customStartDate = null;
      _customEndDate = null;
    }
    notifyListeners();
  }

  void setCustomDateRange(DateTime start, DateTime? end) {
    _dateRange = 'custom';
    _customStartDate = start;
    _customEndDate = end ?? start;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await DbService.setSetting('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setCurrency(String c) async {
    _currency = c;
    await DbService.setSetting('currency', c);
    notifyListeners();
  }

  Future<void> setSavingsGoal(double goal) async {
    _savingsGoal = goal;
    await DbService.setSetting('savingsGoal', goal);
    notifyListeners();
  }

  void _loadAccounts() {
    final raw = DbService.getSetting('accountNames');
    if (raw is List && raw.isNotEmpty) {
      final loaded = raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      const legacyDefaults = {'Cash', 'Bank', 'Credit Card', 'UPI'};
      if (loaded.toSet().containsAll(legacyDefaults) &&
          loaded.length == legacyDefaults.length) {
        _accounts = List<String>.from(AppCategories.accountTypes);
      } else {
        _accounts = loaded;
      }
    } else {
      _accounts = List<String>.from(AppCategories.accountTypes);
    }
    if (_accounts.isEmpty) {
      _accounts = List<String>.from(AppCategories.accountTypes);
    }
  }

  bool isAccountInUse(String name) {
    return _transactions.any((t) => (t['account'] ?? '').toString() == name);
  }

  static const List<Color> _customCategoryColors = [
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDB2777),
    Color(0xFF0891B2),
    Color(0xFF4F46E5),
    Color(0xFFCA8A04),
  ];

  /// Built-in + your custom categories for [type] (`income` / `expense`).
  List<CategoryData> categoriesForType(String type) {
    final builtIn =
        type == 'income' ? AppCategories.income : AppCategories.expense;
    final customNames =
        type == 'income' ? _customIncomeCategories : _customExpenseCategories;
    final builtInLower = builtIn.map((c) => c.name.toLowerCase()).toSet();
    final extras = <CategoryData>[];
    final seenCustom = <String>{};
    for (var i = 0; i < customNames.length; i++) {
      final n = customNames[i];
      if (builtInLower.contains(n.toLowerCase())) continue;
      final key = n.toLowerCase();
      if (!seenCustom.add(key)) continue;
      extras.add(CategoryData(
        name: n,
        icon: Icons.label_outline_rounded,
        color:
            _customCategoryColors[extras.length % _customCategoryColors.length],
      ));
    }
    return [...builtIn, ...extras];
  }

  CategoryData categoryForDisplay(String name, String type) {
    final list = categoriesForType(type);
    for (final c in list) {
      if (c.name == name) return c;
    }
    for (final c in list) {
      if (c.name.toLowerCase() == name.toLowerCase()) return c;
    }
    for (final c in list) {
      if (c.name == 'Other') return c;
    }
    return list.isNotEmpty ? list.last : AppCategories.expense.last;
  }

  List<String> customCategoryNamesOnly(String type) {
    final list =
        type == 'income' ? _customIncomeCategories : _customExpenseCategories;
    return List.unmodifiable(list);
  }

  bool isCategoryInUse(String categoryName) {
    return _transactions
        .any((t) => (t['category'] ?? '').toString() == categoryName);
  }

  Future<String?> addCustomCategory(String type, String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) return 'Enter a name';
    if (name.length > 32) return 'Name is too long (max 32 characters)';
    final mergedLower =
        categoriesForType(type).map((c) => c.name.toLowerCase()).toSet();
    if (mergedLower.contains(name.toLowerCase())) {
      return 'This category already exists';
    }
    if (type == 'income') {
      _customIncomeCategories = [..._customIncomeCategories, name];
    } else {
      _customExpenseCategories = [..._customExpenseCategories, name];
    }
    await _persistCustomCategories();
    notifyListeners();
    return null;
  }

  Future<String?> removeCustomCategory(String type, String name) async {
    final list =
        type == 'income' ? _customIncomeCategories : _customExpenseCategories;
    String? canonical;
    for (final n in list) {
      if (n.toLowerCase() == name.toLowerCase()) {
        canonical = n;
        break;
      }
    }
    if (canonical == null) {
      return 'Only your added categories can be removed';
    }
    if (isCategoryInUse(canonical)) {
      return 'Delete or edit transactions using this category first';
    }
    if (type == 'income') {
      _customIncomeCategories =
          _customIncomeCategories.where((n) => n != canonical).toList();
    } else {
      _customExpenseCategories =
          _customExpenseCategories.where((n) => n != canonical).toList();
    }
    await _persistCustomCategories();
    notifyListeners();
    return null;
  }

  Future<void> _persistCustomCategories() async {
    await DbService.setSetting(
        'customCategoriesExpense', _customExpenseCategories);
    await DbService.setSetting(
        'customCategoriesIncome', _customIncomeCategories);
  }

  void _loadCustomCategories() {
    final e = DbService.getSetting('customCategoriesExpense');
    final i = DbService.getSetting('customCategoriesIncome');
    _customExpenseCategories = _parseStoredCategoryNames(e);
    _customIncomeCategories = _parseStoredCategoryNames(i);
  }

  List<String> _parseStoredCategoryNames(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((x) => x.toString().trim())
        .where((x) => x.isNotEmpty)
        .toList();
  }

  Future<String?> addAccount(String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) return 'Name cannot be empty';
    if (_accounts.any((a) => a.toLowerCase() == name.toLowerCase())) {
      return 'An account with this name already exists';
    }
    _accounts = [..._accounts, name];
    await DbService.setSetting('accountNames', _accounts);
    notifyListeners();
    return null;
  }

  Future<String?> removeAccount(String name) async {
    if (_accounts.length <= 1) return 'Keep at least one account';
    if (isAccountInUse(name)) {
      return 'Reassign or delete transactions using this account first';
    }
    _accounts = _accounts.where((a) => a != name).toList();
    await DbService.setSetting('accountNames', _accounts);
    notifyListeners();
    return null;
  }

  Future<void> applyFullBackup({
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> budgets,
    required Map<String, dynamic> settings,
  }) async {
    await DbService.importFullBackup(
      transactions: transactions,
      budgets: budgets,
      settings: settings,
    );
    loadData();
  }
}
