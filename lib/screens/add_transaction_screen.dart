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
  bool _isPaymentEntry = false;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _partyController = TextEditingController();
  final _purposeController = TextEditingController();
  final _referenceController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();
  DateTime? _serviceFromDate;
  DateTime? _serviceToDate;
  String _selectedAccount = 'Cash';
  String _selectedPaymentMode = 'UPI';
  String _paymentDirection = 'given';
  String _paymentStatus = 'paid';

  String? _titleError;
  String? _amountError;
  String? _partyError;
  String? _purposeError;

  late AnimationController _shakeController;

  bool get _isEditing => widget.transaction != null;

  String _generateReceiptNo() {
    final now = DateTime.now();
    final stamp = DateFormat('yyyyMMddHHmmss').format(now);
    final shortId = now.millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase()
        .padLeft(4, '0')
        .substring(0, 4);
    return 'RCPT-$stamp-$shortId';
  }

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _isPaymentEntry = widget.initialType == 'payment';
    if (_isPaymentEntry) {
      _type = 'expense';
      _paymentDirection = 'given';
    }

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (_isEditing) {
      final t = widget.transaction!;
      _isPaymentEntry = (t['entryType'] ?? '') == 'payment';
      _paymentDirection = t['paymentDirection'] ??
          ((t['type'] ?? 'expense') == 'income' ? 'received' : 'given');
      _type = _isPaymentEntry
          ? (_paymentDirection == 'received' ? 'income' : 'expense')
          : (t['type'] ?? 'expense');
      _titleController.text = t['title'] ?? '';
      _amountController.text = (t['amount'] ?? 0.0).toString();
      _partyController.text = t['partyName'] ?? '';
      _purposeController.text = t['paymentPurpose'] ?? '';
      _referenceController.text = t['reference'] ?? '';
      _noteController.text = t['note'] ?? '';
      _selectedCategory = t['category'] ?? '';
      _selectedDate =
          DateTime.tryParse(t['date'] ?? '') ?? DateTime.now();
      _serviceFromDate = DateTime.tryParse(t['serviceFromDate'] ?? '');
      _serviceToDate = DateTime.tryParse(t['serviceToDate'] ?? '');
      _paymentStatus = t['paymentStatus'] ?? 'paid';
      _selectedPaymentMode = t['paymentMode'] ?? 'UPI';
      _selectedAccount = t['account'] ?? 'Cash';
    } else if (widget.duplicateFrom != null) {
      final t = widget.duplicateFrom!;
      _isPaymentEntry = (t['entryType'] ?? '') == 'payment';
      _paymentDirection = t['paymentDirection'] ??
          ((t['type'] ?? 'expense') == 'income' ? 'received' : 'given');
      _type = _isPaymentEntry
          ? (_paymentDirection == 'received' ? 'income' : 'expense')
          : (t['type'] ?? widget.initialType);
      _titleController.text = t['title'] ?? '';
      _amountController.text = (t['amount'] ?? 0.0).toString();
      _partyController.text = t['partyName'] ?? '';
      _purposeController.text = t['paymentPurpose'] ?? '';
      _referenceController.text = t['reference'] ?? '';
      _noteController.text = t['note'] ?? '';
      _selectedCategory = t['category'] ?? '';
      _selectedDate = DateTime.now();
      _serviceFromDate = DateTime.tryParse(t['serviceFromDate'] ?? '');
      _serviceToDate = DateTime.tryParse(t['serviceToDate'] ?? '');
      _paymentStatus = t['paymentStatus'] ?? 'paid';
      _selectedPaymentMode = t['paymentMode'] ?? 'UPI';
      _selectedAccount = t['account'] ?? 'Cash';
    }

    if (_isPaymentEntry && _referenceController.text.trim().isEmpty) {
      _referenceController.text = _generateReceiptNo();
    }

    if (_selectedCategory.isEmpty) {
      _selectedCategory = _type == 'income'
          ? AppCategories.income.first.name
          : AppCategories.expense.first.name;
    }

    _titleController.addListener(_clearTitleError);
    _amountController.addListener(_clearAmountError);
    _partyController.addListener(_clearPartyError);
    _purposeController.addListener(_clearPurposeError);

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

  void _clearPartyError() {
    if (_partyError != null) setState(() => _partyError = null);
  }

  void _clearPurposeError() {
    if (_purposeError != null) setState(() => _purposeError = null);
  }

  @override
  void dispose() {
    _titleController.removeListener(_clearTitleError);
    _amountController.removeListener(_clearAmountError);
    _partyController.removeListener(_clearPartyError);
    _purposeController.removeListener(_clearPurposeError);
    _titleController.dispose();
    _amountController.dispose();
    _partyController.dispose();
    _purposeController.dispose();
    _referenceController.dispose();
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

      if (_isPaymentEntry) {
        if (_partyController.text.trim().isEmpty) {
          _partyError = 'Enter the person or account name';
          errors.add(_partyError!);
          isValid = false;
        } else {
          _partyError = null;
        }

        if (_purposeController.text.trim().isEmpty) {
          _purposeError = 'Enter the payment purpose';
          errors.add(_purposeError!);
          isValid = false;
        } else {
          _purposeError = null;
        }
      } else {
        _partyError = null;
        _purposeError = null;
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

    if (_isPaymentEntry) {
      data['entryType'] = 'payment';
      data['paymentDirection'] = _paymentDirection;
      data['paymentStatus'] = _paymentStatus;
      data['paymentMode'] = _selectedPaymentMode;
      data['partyName'] = _partyController.text.trim();
      data['paymentPurpose'] = _purposeController.text.trim();
      data['reference'] = _referenceController.text.trim().isEmpty
          ? _generateReceiptNo()
          : _referenceController.text.trim();
      if (_serviceFromDate != null) {
        data['serviceFromDate'] = _serviceFromDate!.toIso8601String();
      }
      if (_serviceToDate != null) {
        data['serviceToDate'] = _serviceToDate!.toIso8601String();
      }
    } else {
      data['entryType'] = 'transaction';
    }

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
          ? '${_isPaymentEntry ? 'Payment' : 'Transaction'} updated successfully!'
          : '${_isPaymentEntry ? 'Payment' : 'Transaction'} added to ${_type == 'income' ? 'income' : 'expenses'}',
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
            Text(_isPaymentEntry ? 'Delete Payment' : 'Delete Transaction',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${_isPaymentEntry ? 'this payment' : 'this transaction'} "${_titleController.text}"?\n\n'
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
        title: Text(
          _isPaymentEntry
              ? (_isEditing ? 'Edit Payment' : 'Add Payment')
              : (_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        ),
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
                  Expanded(
                    child: _buildTypeTab('income', 'Income', AppTheme.income),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeTab('expense', 'Expense', AppTheme.expense),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeTab('payment', 'Payment', AppTheme.secondary),
                  ),
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

            _buildLabel(_isPaymentEntry ? 'Payment Title' : 'Title', isRequired: true),
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
                      hintText: _isPaymentEntry
                          ? 'e.g. Rent for July'
                          : 'e.g. Grocery Shopping',
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

            if (_isPaymentEntry) ...[
              _buildLabel('Paid To / Received From', isRequired: true),
              const SizedBox(height: 8),
              _buildShakeWrapper(
                hasError: _partyError != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _partyController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. Amit, Electricity Board, ABC Store',
                        filled: true,
                        fillColor: _partyError != null
                            ? AppTheme.expense.withValues(alpha: 0.06)
                            : isDark
                                ? AppTheme.darkCardLight
                                : AppTheme.lightCardLight,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _partyError != null
                                ? AppTheme.expense.withValues(alpha: 0.6)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _partyError != null
                                ? AppTheme.expense
                                : AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    _buildInlineError(_partyError),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Why was this payment made?', isRequired: true),
              const SizedBox(height: 8),
              _buildShakeWrapper(
                hasError: _purposeError != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _purposeController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'e.g. Monthly rent, loan return, salary',
                        filled: true,
                        fillColor: _purposeError != null
                            ? AppTheme.expense.withValues(alpha: 0.06)
                            : isDark
                                ? AppTheme.darkCardLight
                                : AppTheme.lightCardLight,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _purposeError != null
                                ? AppTheme.expense.withValues(alpha: 0.6)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _purposeError != null
                                ? AppTheme.expense
                                : AppTheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    _buildInlineError(_purposeError),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel('Payment Direction'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCardLight : AppTheme.lightCardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildDirectionTab('given', 'Given'),
                    _buildDirectionTab('received', 'Received'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel('Payment Mode'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Cash', 'UPI', 'Bank Transfer', 'Card', 'Cheque']
                    .map((mode) {
                  final isSelected = _selectedPaymentMode == mode;
                  return ChoiceChip(
                    label: Text(mode),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) =>
                        setState(() => _selectedPaymentMode = mode),
                    backgroundColor: isDark
                        ? AppTheme.darkCardLight
                        : AppTheme.lightCardLight,
                    selectedColor: AppTheme.secondary.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.secondary
                          : isDark
                              ? Colors.white70
                              : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.secondary : Colors.transparent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _buildLabel('Service Period'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      label: 'From',
                      date: _serviceFromDate,
                      onTap: _pickServiceFromDate,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      label: 'To',
                      date: _serviceToDate,
                      onTap: _pickServiceToDate,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildLabel('Status'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['paid', 'pending'].map((status) {
                  final isSelected = _paymentStatus == status;
                  return ChoiceChip(
                    label: Text(status.toUpperCase()),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _paymentStatus = status),
                    backgroundColor: isDark
                        ? AppTheme.darkCardLight
                        : AppTheme.lightCardLight,
                    selectedColor: AppTheme.secondary.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.secondary
                          : isDark
                              ? Colors.white70
                              : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.secondary : Colors.transparent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              _buildLabel('Reference / Receipt No.'),
              const SizedBox(height: 8),
              TextField(
                controller: _referenceController,
                textCapitalization: TextCapitalization.characters,
                readOnly: _isPaymentEntry,
                decoration: InputDecoration(
                  hintText: 'Auto-generated receipt number',
                  suffixIcon: _isPaymentEntry
                      ? IconButton(
                          tooltip: 'Generate new receipt no.',
                          onPressed: () {
                            setState(() {
                              _referenceController.text = _generateReceiptNo();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 20),
            ],

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

            _buildLabel('Account / Bank'),
            const SizedBox(height: 10),
            Text(
              _isPaymentEntry
                  ? 'Select the source account or bank, e.g. SBI, HDFC, Cash Wallet.'
                  : 'Select the source account or wallet used for this transaction.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
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
                  runSpacing: 8,
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

  Future<void> _pickServiceFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceFromDate ?? _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _serviceFromDate = picked;
        if (_serviceToDate != null && _serviceToDate!.isBefore(picked)) {
          _serviceToDate = picked;
        }
      });
    }
  }

  Future<void> _pickServiceToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceToDate ?? _serviceFromDate ?? _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _serviceToDate = picked;
        if (_serviceFromDate != null && _serviceFromDate!.isAfter(picked)) {
          _serviceFromDate = picked;
        }
      });
    }
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
    final isSelected =
        type == 'payment' ? _isPaymentEntry : (!_isPaymentEntry && _type == type);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isPaymentEntry = type == 'payment';
            _type = type == 'payment'
                ? (_paymentDirection == 'received' ? 'income' : 'expense')
                : type;
            final p = Provider.of<TransactionProvider>(
              context,
              listen: false,
            );
            if (type == 'payment') {
              if (_referenceController.text.trim().isEmpty) {
                _referenceController.text = _generateReceiptNo();
              }
              _selectedCategory = p.categoriesForType(_type).first.name;
            } else {
              _selectedCategory = p.categoriesForType(type).first.name;
            }
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

  Widget _buildDirectionTab(String value, String label) {
    final isSelected = _paymentDirection == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _paymentDirection = value;
            _type = value == 'received' ? 'income' : 'expense';
            final p = Provider.of<TransactionProvider>(
              context,
              listen: false,
            );
            if (_referenceController.text.trim().isEmpty) {
              _referenceController.text = _generateReceiptNo();
            }
            _selectedCategory = p.categoriesForType(_type).first.name;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.secondary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.secondary
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCardLight : AppTheme.lightCardLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date == null
                        ? 'Select date'
                        : DateFormat('dd MMM yyyy').format(date),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
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
