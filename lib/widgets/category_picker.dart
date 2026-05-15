import 'package:flutter/material.dart';
import '../constants/categories.dart';
import '../theme/app_theme.dart';

class CategoryPicker extends StatelessWidget {
  final List<CategoryData> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: categories.map((cat) {
        final isSelected = selectedCategory == cat.name;

        return GestureDetector(
          onTap: () => onSelect(cat.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withValues(alpha: 0.2)
                  : isDark
                      ? AppTheme.darkCardLight
                      : AppTheme.lightCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cat.color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, color: cat.color, size: 18),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? cat.color
                        : isDark
                            ? Colors.white70
                            : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
