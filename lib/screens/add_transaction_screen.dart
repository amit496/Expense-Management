import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../constants/categories.dart';
import '../theme/app_theme.dart';
import '../widgets/category_picker.dart';
import '../utils/message_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  final int? hiveIndex;
  final String initialType;
  final Map<String, dynamic>? duplicateFrom;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.hiveIndex,
    this.initialType = 'expense',
    this.duplicateFrom,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late String _type;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedAccount = 'Cash';

  String? _titleError;
  String? _amountError;

  late AnimationController _shakeController;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (_isEditing) {
      final t = widget.transaction!;
      _type = t['type'] ?? 'expense';
      _titleController.text = t['title'] ?? '';
      _amountController.text = (t['amount'] ?? 0.0).toString();
      _noteController.text = t['note'] ?? '';
      _selectedCategory = t['category'] ?? '';
      _selectedDate =
          DateTime.tryParse(t['date'] ?? '') ?? DateTime.now();
      _selectedAccount = t['account'] ?? 'Cash';
    } else if (widget.duplicateFrom != null) {
      final t = widget.duplicateFrom!;
      _type = t['type'] ?? widget.initialType;
      _titleController.text = t['title'] ?? '';
      _amountController.text = (t['amount'] ?? 0.0).toString();
      _noteController.text = t['note'] ?? '';
      _selectedCategory = t['category'] ?? '';
      _selectedDate = DateTime.now();
      _selectedAccount = t['account'] ?? 'Cash';
    }

    if (_selectedCategory.isEmpty) {
      _selectedCategory = _type == 'income'
          ? AppCategories.income.first.name
          : AppCategories.expense.first.name;
    }

    _titleController.addListener(_clearTitleError);
    _amountController.addListener(_clearAmountError);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = Provider.of<TransactionProvider>(context, listen: false);
      final names = p.categoriesForType(_type).map((c) => c.name).toList();
      if (!names.contains(_selectedCategory)) {
        setState(() => _selectedCategory = names.first);
      }
    });
  }

  void _clearTitleError() {
    if (_titleError != null) setState(() => _titleError = null);
  }

  void _clearAmountError() {
    if (_amountError != null) setState(() => _amountError = null);
  }

  @override
  void dispose() {
    _titleController.removeListener(_clearTitleError);
    _amountController.removeListener(_clearAmountError);
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    final List<String> errors = [];

    setState(() {
      if (_amountController.text.trim().isEmpty) {
        _amountError = 'Amount is required';
        errors.add(_amountError!);
        isValid = false;
      } else {
        final amount = double.tryParse(_amountController.text);
        if (amount == null || amount <= 0) {
          _amountError = 'Enter a valid amount greater than 0';
          errors.add(_amountError!);
          isValid = false;
        } else {
          _amountError = null;
        }
      }

      if (_titleController.text.trim().isEmpty) {
        _titleError = 'Title is required';
        errors.add(_titleError!);
        isValid = false;
      } else {
        _titleError = null;
      }
    });

    if (!isValid) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      if (errors.length > 1) {
        MessageHelper.showError(
            context, 'Please fill in all required fields');
      } else {
        MessageHelper.showError(context, errors.first);
      }
    }

    return isValid;
  }

  void _save() {
    if (!_validate()) return;

    final amount = double.parse(_amountController.text);

    if (amount > 10000000) {
      MessageHelper.showWarning(
          context, 'That\'s a very large amount. Please double-check.');
      return;
    }

    final data = {
      'title': _titleController.text.trim(),
      'amount': amount,
      'category': _selectedCategory,
      'type': _type,
      'date': _selectedDate.toIso8601String(),
      'note': _noteController.text.trim(),
      'account': _selectedAccount,
    };

    final provider =
        Provider.of<TransactionProvider>(context, listen: false);

    if (_isEditing && widget.hiveIndex != null) {
      data['id'] = widget.transaction!['id'];
      provider.updateTransaction(widget.hiveIndex!, data);
    } else {
      provider.addTransaction(data);
    }

    MessageHelper.showSuccess(
      context,
      _isEditing
          ? 'Transaction updated successfully!'
          : 'Transaction added to ${_type == 'income' ? 'income' : 'expenses'}',
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _confirmDelete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expense.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_rounded,
                  color: AppTheme.expense, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Transaction',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_titleController.text}"?\n\n'
          'This will ${_type == 'expense' ? 'add back' : 'remove'} '
          '${Provider.of<TransactionProvider>(context, listen: false).currency}'
          '${_amountController.text} ${_type == 'expense' ? 'to' : 'from'} your balance.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              final provider = Provider.of<TransactionProvider>(
                  context,
                  listen: false);
              if (widget.hiveIndex != null && widget.hiveIndex! >= 0) {
                provider.deleteTransaction(widget.hiveIndex!);
                MessageHelper.showSuccess(
                    context, 'Transaction deleted • Balance updated');
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) Navigator.pop(context);
                });
              }
            },
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expense,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.expense),
              tooltip: 'Delete',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTypeTab('income', 'Income', AppTheme.income),
                  _buildTypeTab('expense', 'Expense', AppTheme.expense),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildLabel('Amount', isRequired: true),
            const SizedBox(height: 8),
            _buildShakeWrapper(
              hasError: _amountError != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText:
                          '${Provider.of<TransactionProvider>(context, listen: false).currency} ',
                      prefixStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(
                        fontSize: 28,
                        color: isDark
                            ? Colors.white12
                            : Colors.grey.shade300,
                      ),
                      filled: true,
                      fillColor: _amountError != null
                          ? AppTheme.expense.withValues(alpha: 0.06)
                          : isDark
                              ? AppTheme.darkCardLight
                              : AppTheme.lightCardLight,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _amountError != null
                              ? AppTheme.expense.withValues(alpha: 0.6)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _amountError != null
                              ? AppTheme.expense
                              : AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  _buildInlineError(_amountError),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel('Title', isRequired: true),
            const SizedBox(height: 8),
            _buildShakeWrapper(
              hasError: _titleError != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'e.g. Grocery Shopping',
                      filled: true,
                      fillColor: _titleError != null
                          ? AppTheme.expense.withValues(alpha: 0.06)
                          : isDark
                              ? AppTheme.darkCardLight
                              : AppTheme.lightCardLight,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _titleError != null
                              ? AppTheme.expense.withValues(alpha: 0.6)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _titleError != null
                              ? AppTheme.expense
                              : AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  _buildInlineError(_titleError),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel('Category'),
            const SizedBox(height: 10),
            Consumer<TransactionProvider>(
              builder: (context, p, _) {
                return CategoryPicker(
                  categories: p.categoriesForType(_type),
                  selectedCategory: _selectedCategory,
                  onSelect: (cat) =>
                      setState(() => _selectedCategory = cat),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildLabel('Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkCardLight
                      : AppTheme.lightCardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, MMM dd, yyyy')
                          .format(_selectedDate),
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel('Account'),
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final txnProvider =
                    Provider.of<TransactionProvider>(context);
                final accountChoices = [...txnProvider.accounts];
                if (_selectedAccount.isNotEmpty &&
                    !accountChoices.contains(_selectedAccount)) {
                  accountChoices.insert(0, _selectedAccount);
                }
                return Wrap(
                  spacing: 8,
                  children: accountChoices.map((account) {
                    final isSelected = _selectedAccount == account;
                    return ChoiceChip(
                      label: Text(account),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (_) =>
                          setState(() => _selectedAccount = account),
                      backgroundColor: isDark
                          ? AppTheme.darkCardLight
                          : AppTheme.lightCardLight,
                      selectedColor:
                          AppTheme.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppTheme.primary
                            : isDark
                                ? Colors.white70
                                : Colors.grey.shade700,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primary
                            : Colors.transparent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildLabel('Note (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isEditing
                        ? 'Update Transaction'
                        : 'Save Transaction',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShakeWrapper({required bool hasError, required Widget child}) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        if (!hasError || !_shakeController.isAnimating) {
          return child!;
        }
        final sineValue =
            _shakeController.value * 3.14159 * 3;
        final dx = (sineValue > 0
                ? (sineValue % 3.14159 < 1.5708 ? 1 : -1)
                : 0) *
            6.0 *
            (1 - _shakeController.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: child,
    );
  }

  Widget _buildInlineError(String? error) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topLeft,
      child: error != null
          ? Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.expense.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: AppTheme.expense,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    error,
                    style: const TextStyle(
                      color: AppTheme.expense,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTypeTab(String type, String label, Color color) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = type;
            final p = Provider.of<TransactionProvider>(
              context,
              listen: false,
            );
            _selectedCategory = p.categoriesForType(type).first.name;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? color
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppTheme.expense,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
