import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../utils/string_extensions.dart';

class CustomCategoryDropdownField extends StatelessWidget {
  final String label;
  final List<Category> items;
  final Category? selectedItem;
  final String? hintText;
  final ValueChanged<Category> onChanged;
  final VoidCallback onManagePressed;

  const CustomCategoryDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    this.hintText,
    required this.onChanged,
    required this.onManagePressed,
  });

  void _showPicker(BuildContext context) {
    int selectedIndex = items.indexWhere((c) => c.id == selectedItem?.id);
    if (selectedIndex == -1) selectedIndex = 0;

    final scrollController = FixedExtentScrollController(
      initialItem: selectedIndex,
    );

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with Manage and Done buttons
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onManagePressed();
                        },
                        child: Text(
                          'Manage'.cased(context),
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Done'.cased(context),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (items.isNotEmpty) {
                            onChanged(items[scrollController.selectedItem]);
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            'No categories'.cased(context),
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.grey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        )
                      : CupertinoPicker(
                          itemExtent: 40.0,
                          scrollController: scrollController,
                          onSelectedItemChanged: (int index) {
                            onChanged(items[index]);
                          },
                          children: items.map((Category value) {
                            return Center(
                              child: Text(
                                value.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: AppColors.textPrimary,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8.0),
        ],
        SizedBox(
          height: 60.0,
          child: InkWell(
            onTap: () => _showPicker(context),
            borderRadius: BorderRadius.circular(12.0),
            child: InputDecorator(
              decoration: _getInputDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedItem?.name ?? hintText ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedItem != null
                            ? AppColors.textPrimary
                            : AppColors.grey,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
