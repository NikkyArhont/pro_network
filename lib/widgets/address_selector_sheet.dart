import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pro_network/services/places_service.dart';

class AddressSelectorSheet extends StatefulWidget {
  final String title;
  final String initialValue;
  final Function(String) onSelected;

  const AddressSelectorSheet({
    super.key,
    required this.title,
    this.initialValue = '',
    required this.onSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String initialValue = '',
    required Function(String) onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressSelectorSheet(
        title: title,
        initialValue: initialValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  State<AddressSelectorSheet> createState() => _AddressSelectorSheetState();
}

class _AddressSelectorSheetState extends State<AddressSelectorSheet> {
  late TextEditingController _searchController;
  final PlacesService _placesService = PlacesService();
  Timer? _debounce;
  List<String> _suggestions = [];
  bool _isLoading = false;

  final List<String> _mockSuggestions = [
    'г. Омск, Омская обл., Россия',
    'г. Орёл, Орловская обл., Россия',
    'г. Оренбург, Оренбургская обл., Россия',
    'г. Онега, Архангельская обл., Россия',
    'г. Остров, Псковская обл., Россия',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue);
    // If we have an initial value, maybe we don't want to search immediately
    // or maybe we do. We'll leave it empty unless they type.
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
        return;
      }

      setState(() => _isLoading = true);
      final results = await _placesService.fetchSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
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
                  if (_searchController.text.isNotEmpty)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Результаты поиска',
                                  style: TextStyle(
                                    color: Color(0xFFC6C6C6),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                if (_isLoading) ...[
                                  const SizedBox(width: 10),
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8E30)),
                                  ),
                                ]
                              ],
                            ),
                            const SizedBox(height: 15),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: _suggestions.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 13),
                                itemBuilder: (context, index) {
                                  final suggestion = _suggestions[index];
                                  return GestureDetector(
                                    onTap: () {
                                      widget.onSelected(suggestion);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      suggestion,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
