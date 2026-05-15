import 'package:hive/hive.dart';

class DbService {
  static late Box _transactionBox;
  static late Box _budgetBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    _transactionBox = await Hive.openBox('transactions');
    _budgetBox = await Hive.openBox('budgets');
    _settingsBox = await Hive.openBox('settings');
    await _migrateOldData();
  }

  static Future<void> _migrateOldData() async {
    try {
      if (await Hive.boxExists('expenses')) {
        final oldBox = await Hive.openBox('expenses');
        if (oldBox.isNotEmpty && _transactionBox.isEmpty) {
          int counter = 0;
          for (var item in oldBox.values) {
            if (item is Map) {
              final data = Map<String, dynamic>.from(item);
              data['type'] ??= 'expense';
              data['id'] ??=
                  '${DateTime.now().millisecondsSinceEpoch}_$counter';
              data['note'] ??= '';
              data['account'] ??= 'Cash';
              await _transactionBox.add(data);
              counter++;
            }
          }
        }
        await oldBox.close();
      }
    } catch (_) {}
  }

  static Box get transactionBox => _transactionBox;
  static Box get budgetBox => _budgetBox;
  static Box get settingsBox => _settingsBox;

  static List<Map<String, dynamic>> getAllTransactions() {
    return _transactionBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> addTransaction(Map<String, dynamic> data) async {
    await _transactionBox.add(data);
  }

  static Future<void> updateTransaction(
      int index, Map<String, dynamic> data) async {
    await _transactionBox.putAt(index, data);
  }

  static Future<void> deleteTransaction(int index) async {
    await _transactionBox.deleteAt(index);
  }

  static List<Map<String, dynamic>> getAllBudgets() {
    return _budgetBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> saveBudget(Map<String, dynamic> data) async {
    final allBudgets = _budgetBox.values.toList();
    final index = allBudgets.indexWhere((e) =>
        e['category'] == data['category'] && e['month'] == data['month']);

    if (index >= 0) {
      await _budgetBox.putAt(index, data);
    } else {
      await _budgetBox.add(data);
    }
  }

  static Future<void> deleteBudget(int index) async {
    await _budgetBox.deleteAt(index);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Full local backup restore: replaces transactions, budgets, and all settings keys.
  static Future<void> importFullBackup({
    required List<Map<String, dynamic>> transactions,
    required List<Map<String, dynamic>> budgets,
    required Map<String, dynamic> settings,
  }) async {
    await _transactionBox.clear();
    await _budgetBox.clear();
    final settingKeys = _settingsBox.keys.toList();
    for (final k in settingKeys) {
      await _settingsBox.delete(k);
    }
    for (final t in transactions) {
      await _transactionBox.add(Map<String, dynamic>.from(t));
    }
    for (final b in budgets) {
      await _budgetBox.add(Map<String, dynamic>.from(b));
    }
    for (final e in settings.entries) {
      await _settingsBox.put(e.key, e.value);
    }
  }

  static Map<String, dynamic> dumpAllSettings() {
    final m = <String, dynamic>{};
    for (final k in _settingsBox.keys) {
      m[k.toString()] = _settingsBox.get(k);
    }
    return m;
  }
}
