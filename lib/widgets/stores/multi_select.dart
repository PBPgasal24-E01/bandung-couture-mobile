/// MultiSelect interface
/// > Receives two lists of strings parameters: possible options and initial options
/// > Returns a list of strings: selected options
/// > If empty string is given in initial options, indicating that "all" option is initially
/// selected and no other is selected
/// > If empty string is returned, indicating that "all" option is returned, and this
/// is equivalent with the fact that the empty string is the only element in the list

import 'package:flutter/material.dart';

class MultiSelect extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> initialItems;

  const MultiSelect({
    super.key,
    required this.title,
    required this.items,
    required this.initialItems,
  });

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  late final List<String> _selectedItems;

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      //"" here represents that every category is selected
      if (itemValue == "") {
        // If "" (all) is selected, clear other selections
        if (isSelected) {
          _selectedItems
            ..clear()
            ..add("");
        } else {
          _selectedItems.remove("");
        }
      } else {
        // For other items, deselect "" (All) if selected
        _selectedItems.remove("");
        isSelected
            ? _selectedItems.add(itemValue)
            : _selectedItems.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialItems);
    if (_selectedItems.contains("")) {
      _selectedItems.clear();
      _selectedItems.add("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Add "All" checkbox at the top
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CheckboxListTile(
                  value: _selectedItems.contains(""),
                  title: const Text(
                    "All",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => _itemChange("", isChecked ?? false),
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                ),
              ),

              // Dynamically generate other checkboxes
              ...widget.items.map((item) {
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) =>
                        _itemChange(item, isChecked ?? false),
                    activeColor: Colors.black,
                    checkColor: Colors.white,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),

        // Submit Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _submit,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
