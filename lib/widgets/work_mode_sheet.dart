import 'package:flutter/material.dart';
import 'package:pro_network/models/business_card_draft.dart';

class WorkModeSheet extends StatefulWidget {
  final WorkMode initialWorkMode;
  final Function(WorkMode) onSave;

  const WorkModeSheet({
    super.key,
    required this.initialWorkMode,
    required this.onSave,
  });

  static void show(BuildContext context, {required WorkMode initialWorkMode, required Function(WorkMode) onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF01191B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WorkModeSheet(
        initialWorkMode: initialWorkMode,
        onSave: onSave,
      ),
    );
  }

  @override
  State<WorkModeSheet> createState() => _WorkModeSheetState();
}

class _WorkModeSheetState extends State<WorkModeSheet> {
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late List<String> _selectedDays;
  final List<String> _allDays = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье'
  ];

  @override
  void initState() {
    super.initState();
    _startCtrl = TextEditingController(text: widget.initialWorkMode.startTime);
    _endCtrl = TextEditingController(text: widget.initialWorkMode.endTime);
    _selectedDays = List.from(widget.initialWorkMode.workDays);
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Режим работы',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Часы',
              style: TextStyle(color: Color(0xFFFF8E30), fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTimeInput(_startCtrl, '10:00')),
              const SizedBox(width: 10),
              Expanded(child: _buildTimeInput(_endCtrl, '19:00')),
            ],
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Дни недели',
              style: TextStyle(color: Color(0xFFFF8E30), fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          ..._allDays.map((day) {
            final isSelected = _selectedDays.contains(day);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                },
                child: isSelected
                    ? Container(
                        width: double.infinity,
                        height: 29,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF557578),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.check, size: 12, color: Color(0xFF557578)),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 29,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          day,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF334D50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              onTap: () {
                final result = WorkMode(
                  startTime: _startCtrl.text,
                  endTime: _endCtrl.text,
                  workDays: _selectedDays,
                );
                widget.onSave(result);
                Navigator.pop(context);
              },
              child: const Center(
                child: Text('Сохранить', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String hint) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF637B7E)),
            border: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.datetime,
        ),
      ),
    );
  }
}
