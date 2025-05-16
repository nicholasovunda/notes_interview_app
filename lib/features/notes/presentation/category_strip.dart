import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app_interview/features/category/domain/category.dart';
import 'package:notes_app_interview/features/notes/data/notes_database.dart';

class CategoryStrip extends ConsumerWidget {
  final Category? selectedCategory;
  final Function(Category?) onCategorySelected;

  const CategoryStrip({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoriesProvider);

    return categoryState.when(
      data:
          (categories) => SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildChip(context, null, "All");
                } else {
                  final category = categories[index - 1];
                  return _buildChip(context, category, category.name);
                }
              },
            ),
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Error loading categories")),
    );
  }

  Widget _buildChip(BuildContext context, Category? category, String label) {
    final bool isSelected =
        category?.id == selectedCategory?.id ||
        (category == null && selectedCategory == null);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onCategorySelected(category),
      selectedColor: Colors.black,
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}
