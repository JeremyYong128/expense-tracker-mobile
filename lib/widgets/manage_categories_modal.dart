import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../utils/string_extensions.dart';
import '../services/data_service.dart';

class ManageCategoriesModal extends StatefulWidget {
  final List<Category> initialCategories;
  final ValueChanged<List<Category>> onCategoriesUpdated;
  final ValueChanged<Category>? onCategorySelected;

  const ManageCategoriesModal({
    super.key,
    required this.initialCategories,
    required this.onCategoriesUpdated,
    this.onCategorySelected,
  });

  @override
  State<ManageCategoriesModal> createState() => _ManageCategoriesModalState();
}

class _ManageCategoriesModalState extends State<ManageCategoriesModal> {
  late List<Category> _categories;
  final TextEditingController _addController = TextEditingController();

  // Track which index is being edited
  int? _editingIndex;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.initialCategories);
  }

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    final text = _addController.text.trim();
    if (text.isNotEmpty &&
        !_categories.any(
          (c) => c.name.toLowerCase() == text.toLowerCase(),
        )) {
      final newCategory = Category(name: text, iconString: 'category', colorHex: '#9E9E9E');
      final newId = await DataService.addCategory(newCategory);
      
      setState(() {
        _categories.add(
          Category(id: newId, name: text, iconString: 'category', colorHex: '#9E9E9E'),
        );
      });
      _addController.clear();
      widget.onCategoriesUpdated(_categories);
    }
  }

  Future<void> _deleteCategory(int index) async {
    final category = _categories[index];
    if (category.id != null) {
      await DataService.deleteCategory(category.id!);
    }
    
    setState(() {
      _categories.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
      }
    });
    widget.onCategoriesUpdated(_categories);
  }

  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      _editController.text = _categories[index].name;
    });
  }

  Future<void> _saveEdit(int index) async {
    final text = _editController.text.trim();
    final existing = _categories[index];

    if (text.isEmpty ||
        _categories.any(
          (c) =>
              c.name.toLowerCase() == text.toLowerCase() &&
              _categories.indexOf(c) != index,
        )) {
      setState(() {
        _editingIndex = null;
      });
      return;
    }

    if (text == existing.name) {
      setState(() {
        _editingIndex = null;
      });
      return;
    }

    final option = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'.cased(context)),
          content: Text('Do you want to apply this change to all past transactions, or only to new transactions?'.cased(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(0), // Cancel
              child: Text('Cancel'.cased(context)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(1),
              child: Text('All Past'.cased(context)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(2),
              child: Text('Only New'.cased(context)),
            ),
          ],
        );
      },
    );

    if (option == null || option == 0) {
      setState(() {
        _editingIndex = null;
      });
      return;
    }

    if (option == 1) {
      final updatedCategory = Category(
        id: existing.id,
        name: text,
        colorHex: existing.colorHex,
        iconString: existing.iconString,
      );
      final newId = await DataService.updateCategory(updatedCategory);
      setState(() {
        _categories[index] = Category(
          id: newId,
          name: updatedCategory.name,
          colorHex: updatedCategory.colorHex,
          iconString: updatedCategory.iconString,
          isActive: updatedCategory.isActive,
        );
        _editingIndex = null;
      });
    } else if (option == 2) {
      if (existing.id != null) {
        await DataService.deleteCategory(existing.id!);
      }
      final newCategory = Category(
        name: text,
        colorHex: existing.colorHex,
        iconString: existing.iconString,
      );
      final newId = await DataService.addCategory(newCategory);
      setState(() {
        _categories[index] = Category(
          id: newId,
          name: text,
          colorHex: existing.colorHex,
          iconString: existing.iconString,
        );
        _editingIndex = null;
      });
    }

    widget.onCategoriesUpdated(_categories);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage categories'.cased(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Add New Category Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: InputDecoration(
                      hintText: 'Add new category...'.cased(context),
                      hintStyle: const TextStyle(color: AppColors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _addCategory(),
                  ),
                ),
                const SizedBox(width: 12.0),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _addCategory,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: _categories.isEmpty
                ? Center(
                    child: Text(
                      'No categories available'.cased(context),
                      style: const TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isEditing = _editingIndex == index;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: InkWell(
                          onTap: () {
                            if (!isEditing &&
                                widget.onCategorySelected != null) {
                              widget.onCategorySelected!(_categories[index]);
                            }
                          },
                          borderRadius: BorderRadius.circular(12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: isEditing
                                      ? TextField(
                                          controller: _editController,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                          ),
                                          onSubmitted: (_) => _saveEdit(index),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            _categories[index].name.cased(context),
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                ),
                                if (isEditing)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check,
                                      color: AppColors.income,
                                    ),
                                    onPressed: () => _saveEdit(index),
                                  )
                                else ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.grey,
                                    ),
                                    onPressed: () => _startEditing(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: AppColors.expense,
                                    ),
                                    onPressed: () => _deleteCategory(index),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
