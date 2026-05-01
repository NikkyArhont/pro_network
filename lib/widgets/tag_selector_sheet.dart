import 'package:flutter/material.dart';
import 'package:pro_network/utils/constants.dart';
import 'package:pro_network/services/tag_service.dart';

class TagSelectorSheet extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onSave;

  const TagSelectorSheet({
    super.key,
    required this.initialTags,
    required this.onSave,
  });

  static void show(BuildContext context, {required List<String> initialTags, required Function(List<String>) onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TagSelectorSheet(
        initialTags: initialTags,
        onSave: onSave,
      ),
    );
  }

  @override
  State<TagSelectorSheet> createState() => _TagSelectorSheetState();
}

class _TagSelectorSheetState extends State<TagSelectorSheet> {
  late List<String> _selectedTags;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TagService _tagService = TagService();
  List<String> _allTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _tagService.getAllTags();
    if (mounted) {
      setState(() {
        _allTags = tags;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTags = _allTags
        .where((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final hasExactMatch = _allTags.any((tag) => tag.toLowerCase() == _searchQuery.toLowerCase()) ||
                          _selectedTags.any((tag) => tag.toLowerCase() == _searchQuery.toLowerCase());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 30),
      // We want to limit height to a reasonable amount
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const ShapeDecoration(
        color: Color(0xFF11292B),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFF0C3135)),
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
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF334D50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Выберите теги',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // Search Field
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C3135),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF637B7E), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Поиск тегов...',
                      hintStyle: TextStyle(color: Color(0xFF637B7E)),
                      border: InputBorder.none,
                      isDense: true,
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close, color: Color(0xFF637B7E), size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Tags List
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTags.isNotEmpty) ...[
                    const Text(
                      'Выбрано',
                      style: TextStyle(color: Color(0xFF637B7E), fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _selectedTags.map((tag) => _buildTag(tag, true)).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFF0C3135)),
                    const SizedBox(height: 10),
                  ],
                  if (!hasExactMatch && _searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_selectedTags.contains(_searchQuery)) {
                            _selectedTags.add(_searchQuery);
                          }
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C3135),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFF8E30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, color: Color(0xFFFF8E30), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Создать тег: "$_searchQuery"',
                              style: const TextStyle(color: Color(0xFFFF8E30), fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (filteredTags.isNotEmpty) ...[
                    const Text(
                      'Все теги',
                      style: TextStyle(color: Color(0xFF637B7E), fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: filteredTags.map((tag) => _buildTag(tag, _selectedTags.contains(tag))).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Reset Button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTags.clear();
              });
              widget.onSave(_selectedTags);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFF557578)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Сбросить',
                style: TextStyle(color: Color(0xFF637B7E), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Save Button
          GestureDetector(
            onTap: () {
              widget.onSave(_selectedTags);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFF334D50),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFF557578)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Сохранить',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 2 : 1,
              color: isSelected ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(Icons.close, size: 12, color: Color(0xFFFF8E30)),
            ],
          ],
        ),
      ),
    );
  }
}
