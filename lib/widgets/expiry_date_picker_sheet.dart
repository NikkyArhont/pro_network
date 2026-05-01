import 'package:flutter/material.dart';

class ExpiryDatePickerSheet extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime start, DateTime end) onSave;
  final VoidCallback onReset;

  const ExpiryDatePickerSheet({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onSave,
    required this.onReset,
  });

  @override
  State<ExpiryDatePickerSheet> createState() => _ExpiryDatePickerSheetState();
}

class _ExpiryDatePickerSheetState extends State<ExpiryDatePickerSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  
  final List<String> _months = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  void _showPicker(String title, List<String> options, int initialIndex, Function(int) onSelected) {
    int currentIndex = initialIndex;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF11292B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Highlight Lines
                  Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFFF8E30), width: 1),
                        bottom: BorderSide(color: Color(0xFFFF8E30), width: 1),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      controller: FixedExtentScrollController(initialItem: initialIndex),
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (idx) {
                        currentIndex = idx;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: options.length,
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              options[index],
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  onSelected(currentIndex);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8E30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('Выбрать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  bool get _isValid {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !_startDate.isBefore(today) && !_endDate.isBefore(_startDate);
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Stack(
            children: [
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Срок действия предложения',
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
          
          // Select Period Section
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              const Text(
                'Выбрать период',
                style: TextStyle(
                  color: Color(0xFFFF8E30),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              // Date Row 1 (Start Date - Editable)
              Row(
                spacing: 5,
                children: [
                  _buildDateComponent(
                    _startDate.day.toString(),
                    onTap: () {
                      final maxDays = _daysInMonth(_startDate.year, _startDate.month);
                      final days = List.generate(maxDays, (i) => (i + 1).toString());
                      _showPicker('День начала', days, _startDate.day - 1, (idx) {
                        setState(() => _startDate = DateTime(_startDate.year, _startDate.month, idx + 1));
                      });
                    },
                  ),
                  _buildDateComponent(
                    _months[_startDate.month - 1],
                    onTap: () {
                      _showPicker('Месяц начала', _months, _startDate.month - 1, (idx) {
                        final newMonth = idx + 1;
                        final maxDays = _daysInMonth(_startDate.year, newMonth);
                        final newDay = _startDate.day > maxDays ? maxDays : _startDate.day;
                        setState(() => _startDate = DateTime(_startDate.year, newMonth, newDay));
                      });
                    },
                  ),
                  _buildDateComponent(
                    _startDate.year.toString(),
                    onTap: () {
                      final currentYear = DateTime.now().year;
                      final years = List.generate(10, (i) => (currentYear + i).toString());
                      _showPicker('Год начала', years, _startDate.year - currentYear, (idx) {
                        final newYear = currentYear + idx;
                        final maxDays = _daysInMonth(newYear, _startDate.month);
                        final newDay = _startDate.day > maxDays ? maxDays : _startDate.day;
                        setState(() => _startDate = DateTime(newYear, _startDate.month, newDay));
                      });
                    },
                  ),
                ],
              ),
              
              // Date Row 2 (End Date - Editable)
              Row(
                spacing: 5,
                children: [
                  _buildDateComponent(
                    _endDate.day.toString(),
                    onTap: () {
                      final maxDays = _daysInMonth(_endDate.year, _endDate.month);
                      final days = List.generate(maxDays, (i) => (i + 1).toString());
                      _showPicker('День окончания', days, _endDate.day - 1, (idx) {
                        setState(() => _endDate = DateTime(_endDate.year, _endDate.month, idx + 1));
                      });
                    },
                  ),
                  _buildDateComponent(
                    _months[_endDate.month - 1],
                    onTap: () {
                      _showPicker('Месяц окончания', _months, _endDate.month - 1, (idx) {
                        final newMonth = idx + 1;
                        final maxDays = _daysInMonth(_endDate.year, newMonth);
                        final newDay = _endDate.day > maxDays ? maxDays : _endDate.day;
                        setState(() => _endDate = DateTime(_endDate.year, newMonth, newDay));
                      });
                    },
                  ),
                  _buildDateComponent(
                    _endDate.year.toString(),
                    onTap: () {
                      final currentYear = DateTime.now().year;
                      final years = List.generate(10, (i) => (currentYear + i).toString());
                      _showPicker('Год окончания', years, _endDate.year - currentYear, (idx) {
                        final newYear = currentYear + idx;
                        final maxDays = _daysInMonth(newYear, _endDate.month);
                        final newDay = _endDate.day > maxDays ? maxDays : _endDate.day;
                        setState(() => _endDate = DateTime(newYear, _endDate.month, newDay));
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Save Button
          GestureDetector(
            onTap: _isValid ? () {
              widget.onSave(_startDate, _endDate);
              Navigator.pop(context);
            } : null,
            child: Opacity(
              opacity: _isValid ? 1.0 : 0.6,
              child: Container(
                width: double.infinity,
                height: 45,
                decoration: ShapeDecoration(
                  color: _isValid ? const Color(0xFF334D50) : const Color(0x33FF0000),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: _isValid ? const Color(0xFF557578) : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Сохранить',
                  style: TextStyle(
                    color: _isValid ? Colors.white : Colors.red[200],
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.10,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),

          // Reset Button
          GestureDetector(
            onTap: () {
              widget.onReset();
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: 45,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF557578),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Сбросить период действия',
                style: TextStyle(
                  color: Color(0xFF637B7E),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.10,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          
          // Bottom Indicator
          Center(
            child: Container(
              width: 139,
              height: 5,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateComponent(String label, {VoidCallback? onTap, bool enabled = true}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 45,
          decoration: ShapeDecoration(
            color: const Color(0xFF334D50),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFF557578),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              letterSpacing: 0.10,
            ),
          ),
        ),
      ),
    );
  }
}
