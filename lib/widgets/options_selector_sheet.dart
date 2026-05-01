import 'package:flutter/material.dart';

class OptionsSelectorSheet extends StatefulWidget {
  final String title;
  final String initialValue;
  final List<String> options;
  final Function(String) onSelected;

  const OptionsSelectorSheet({
    super.key,
    required this.title,
    this.initialValue = '',
    required this.options,
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String initialValue = '',
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OptionsSelectorSheet(
        title: title,
        initialValue: initialValue,
        options: options,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<OptionsSelectorSheet> createState() => _OptionsSelectorSheetState();
}

class _OptionsSelectorSheetState extends State<OptionsSelectorSheet> {
  late TextEditingController _searchController;
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredOptions = widget.options;
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredOptions = widget.options;
      } else {
        _filteredOptions = widget.options
            .where((opt) => opt.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 450,
      padding: const EdgeInsets.only(
        top: 20,
        left: 10,
        right: 10,
        bottom: 30,
      ),
      decoration: const ShapeDecoration(
        color: Color(0xFF11292B),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignOutside,
            color: Color(0xFF0C3135),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        shadows: [
          BoxShadow(
            color: Color(0xCC000000),
            blurRadius: 20,
            offset: Offset(0, -20),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Field and Results
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const ShapeDecoration(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    width: double.infinity,
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: ShapeDecoration(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF557578),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Поиск...',
                        hintStyle: TextStyle(color: Color(0xFFC6C6C6)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        filled: false,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  // Suggestions
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _filteredOptions.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 13),
                              itemBuilder: (context, index) {
                                final option = _filteredOptions[index];
                                final isSelected = option == widget.initialValue;
                                return GestureDetector(
                                  onTap: () {
                                    widget.onSelected(option);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFFFF8E30) : Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
