import 'package:flutter/material.dart';
import 'package:expense_tracker_mobile/ui/widgets/slide_up_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker_mobile/utils/app_theme.dart';
import 'package:expense_tracker_mobile/models/category.dart';
import 'package:expense_tracker_mobile/utils/string_extensions.dart';
import 'package:expense_tracker_mobile/services/data_service.dart';
import 'package:expense_tracker_mobile/utils/category_appearance.dart';
import 'package:expense_tracker_mobile/ui/widgets/category_appearance_picker_modal.dart';
import 'package:expense_tracker_mobile/ui/widgets/custom_validated_field.dart';

class EditCategoriesModal extends StatefulWidget {
  final List<Category> initialCategories;
  final ValueChanged<List<Category>> onCategoriesUpdated;
  final ValueChanged<Category>? onCategorySelected;

  const EditCategoriesModal({
    super.key,
    required this.initialCategories,
    required this.onCategoriesUpdated,
    this.onCategorySelected,
  });

  @override
  State<EditCategoriesModal> createState() => _EditCategoriesModalState();
}

class _EditCategoriesModalState extends State<EditCategoriesModal> {
  late List<Category> _categories;
  final TextEditingController _addController = TextEditingController();

  // Track which index is being edited
  int? _editingIndex;
  final TextEditingController _editController = TextEditingController();

  String _newCategoryIcon = 'category';

  String _newCategoryColorHex = '#9E9E9E';
  
  String? _formError;
  final _addFormKey = GlobalKey<FormState>();

  void _showAppearancePicker({
    required String initialIcon,
    required String initialColorHex,
    required Function(String, String) onSave,
  }) {
    SlideUpModal.showCustom(
      context: context,
      builder: (ctx) => CategoryAppearancePicker(
        initialIcon: initialIcon,
        initialColorHex: initialColorHex,
        onSave: onSave,
      ),
    );
  }

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
    setState(() => _formError = null);
    if (!_addFormKey.currentState!.validate()) return;

    final text = _addController.text.trim();
    
    try {
      final newCategory = Category(
        name: text,
        iconString: _newCategoryIcon,
        colorHex: _newCategoryColorHex,
      );
      final newId = await DataService.addCategory(newCategory);

      setState(() {
        _categories.add(
          Category(
            id: newId,
            name: text,
            iconString: _newCategoryIcon,
            colorHex: _newCategoryColorHex,
          ),
        );
        _newCategoryIcon = 'category';
        _newCategoryColorHex = '#9E9E9E';
      });
      _addController.clear();
      widget.onCategoriesUpdated(_categories);
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _deleteCategory(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Category?'.cased(context)),
          content: Text(
            'This will not affect existing transactions under this category.'
                .cased(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'.cased(context)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Delete'.cased(context),
                style: const TextStyle(color: AppColors.expense),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _formError = null);
    
    try {
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
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
          content: Text(
            'Do you want to apply this change to all past transactions, or only to new transactions?'
                .cased(context),
          ),
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

    setState(() => _formError = null);
    
    try {
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideUpModal(
      title: 'Edit categories',
      heightFraction: 0.7,
      child: Column(
        children: [
          if (_formError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _formError!,
                style: const TextStyle(
                  color: AppColors.expense,
                  fontSize: 14,
                ),
              ),
            ),
          // Add New Category Row
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Form(
              key: _addFormKey,
              child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _showAppearancePicker(
                      initialIcon: _newCategoryIcon,
                      initialColorHex: _newCategoryColorHex,
                      onSave: (icon, color) {
                        setState(() {
                          _newCategoryIcon = icon;
                          _newCategoryColorHex = color;
                        });
                      },
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CategoryAppearance.getColorFromHex(
                        _newCategoryColorHex,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CategoryAppearance.getIconData(_newCategoryIcon),
                      color: CategoryAppearance.getColorFromHex(
                        _newCategoryColorHex,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: CustomValidatedField(
                    padding: EdgeInsets.zero,
                    validator: () {
                      final text = _addController.text.trim();
                      if (text.isEmpty) {
                        return 'Category name is required';
                      }
                      if (_categories.any((c) => c.name.toLowerCase() == text.toLowerCase())) {
                        return 'Category already exists';
                      }
                      return null;
                    },
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
          ),

          // Categories List
          Expanded(
            child: _categories.isEmpty
                ? Center(
                    child: Text(
                      'No categories available'.cased(context),
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isEditing = _editingIndex == index;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
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
                                GestureDetector(
                                  onTap: () {
                                    _showAppearancePicker(
                                      initialIcon:
                                          _categories[index].iconString ??
                                          'category',
                                      initialColorHex:
                                          _categories[index].colorHex ??
                                          '#9E9E9E',
                                      onSave: (icon, color) async {
                                        final updatedCategory = Category(
                                          id: _categories[index].id,
                                          name: _categories[index].name,
                                          iconString: icon,
                                          colorHex: color,
                                          isActive: _categories[index].isActive,
                                        );
                                        final newId =
                                            await DataService.updateCategory(
                                              updatedCategory,
                                            );
                                        setState(() {
                                          _categories[index] = Category(
                                            id: newId,
                                            name: updatedCategory.name,
                                            colorHex: updatedCategory.colorHex,
                                            iconString:
                                                updatedCategory.iconString,
                                            isActive: updatedCategory.isActive,
                                          );
                                        });
                                        widget.onCategoriesUpdated(_categories);
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    margin: const EdgeInsets.only(right: 12.0),
                                    decoration: BoxDecoration(
                                      color: _categories[index].color
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _categories[index].iconData,
                                      color: _categories[index].color,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: isEditing
                                      ? CustomValidatedField(
                                          padding: EdgeInsets.zero,
                                          validator: () {
                                            final text = _editController.text.trim();
                                            if (text.isEmpty) {
                                              return 'Name is required';
                                            }
                                            if (_categories.any((c) => c.name.toLowerCase() == text.toLowerCase() && _categories.indexOf(c) != index)) {
                                              return 'Category already exists';
                                            }
                                            return null;
                                          },
                                          child: TextField(
                                            controller: _editController,
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              border: InputBorder.none,
                                            ),
                                            onSubmitted: (_) => _saveEdit(index),
                                          ),
                                        )
                                      : GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => _startEditing(index),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(
                                              _categories[index].name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
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
