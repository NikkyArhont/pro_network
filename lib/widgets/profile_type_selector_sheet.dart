import 'package:flutter/material.dart';

class ProfileTypeSelectorSheet extends StatefulWidget {
  final String selectedType;
  final Function(String) onSelect;

  const ProfileTypeSelectorSheet({
    super.key,
    required this.selectedType,
    required this.onSelect,
  });

  static void show(BuildContext context, {required String selectedType, required Function(String) onSelect}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileTypeSelectorSheet(
        selectedType: selectedType,
        onSelect: onSelect,
      ),
    );
  }

  @override
  State<ProfileTypeSelectorSheet> createState() => _ProfileTypeSelectorSheetState();
}

class _ProfileTypeSelectorSheetState extends State<ProfileTypeSelectorSheet> {
  late String _tempSelectedType;

  @override
  void initState() {
    super.initState();
    _tempSelectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 20,
        left: 10,
        right: 10,
        bottom: 30,
      ),
      decoration: ShapeDecoration(
        color: const Color(0xFF11292B),
        shape: const RoundedRectangleBorder(
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
          const BoxShadow(
            color: Color(0xCC000000),
            blurRadius: 20,
            offset: Offset(0, -20),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          SizedBox(
            width: double.infinity,
            height: 30,
            child: Stack(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Тип профиля',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                  right: 10,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Options Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildModernOption('Все', 'all'),
              const SizedBox(width: 10),
              _buildModernOption('Личный', 'user'),
              const SizedBox(width: 10),
              _buildModernOption('Визитка', 'card'),
            ],
          ),
          const SizedBox(height: 24),
          // Save Button
          GestureDetector(
            onTap: () {
              widget.onSelect(_tempSelectedType);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 6),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Bottom Handle
          Container(
            width: 139,
            height: 5,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOption(String label, String value) {
    final bool isSelected = _tempSelectedType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSelectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 2 : 1,
              color: isSelected ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
