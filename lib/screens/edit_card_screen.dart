import 'package:flutter/material.dart';
import 'package:pro_network/models/business_card_draft.dart';
import 'package:pro_network/widgets/category_selector_sheet.dart';
import 'package:pro_network/widgets/work_mode_sheet.dart';
import 'package:pro_network/widgets/tag_selector_sheet.dart';
import 'package:pro_network/services/business_card_service.dart';

class EditCardScreen extends StatefulWidget {
  final BusinessCardDraft card;
  final String? cardId;

  const EditCardScreen({
    super.key,
    required this.card,
    this.cardId,
  });

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _companyController;
  late TextEditingController _directionController;
  late TextEditingController _cityController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _telegramController;
  late TextEditingController _vkController;
  late String _selectedCategory;
  late WorkMode _workMode;
  late List<String> _selectedTags;
  bool _isLoading = false;
  final BusinessCardService _cardService = BusinessCardService();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.card.category;
    _workMode = widget.card.workMode;
    _selectedTags = List.from(widget.card.tags);
    _nameController = TextEditingController(text: widget.card.name);
    _positionController = TextEditingController(text: widget.card.position);
    _companyController = TextEditingController(text: widget.card.company);
    _directionController = TextEditingController(text: widget.card.activityDirection);
    _cityController = TextEditingController(text: widget.card.city);
    _descriptionController = TextEditingController(text: widget.card.description);
    _addressController = TextEditingController(text: widget.card.workAddress);
    _phoneController = TextEditingController(text: widget.card.phone);
    _emailController = TextEditingController(text: widget.card.email);
    _websiteController = TextEditingController(text: widget.card.website);
    _telegramController = TextEditingController(text: widget.card.telegram);
    _vkController = TextEditingController(text: widget.card.vk);

    // Add listeners to refresh preview header when typing
    _nameController.addListener(() => setState(() {}));
    _positionController.addListener(() => setState(() {}));
    _companyController.addListener(() => setState(() {}));
    _directionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _companyController.dispose();
    _directionController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _telegramController.dispose();
    _vkController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (widget.cardId == null || widget.cardId!.isEmpty) {
      print('CRITICAL ERROR: cardId is null or empty in EditCardScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: не удалось определить ID визитки.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> updatedData = {
        'name': _nameController.text,
        'position': _positionController.text,
        'company': _companyController.text,
        'category': _selectedCategory,
        'activityDirection': _directionController.text,
        'city': _cityController.text,
        'description': _descriptionController.text,
        'tags': _selectedTags,
        'address': _addressController.text,
        'workMode': _workMode.toMap(),
        'phone': _phoneController.text,
        'email': _emailController.text,
        'website': _websiteController.text,
        'telegram': _telegramController.text,
        'vkontakte': _vkController.text,
      };

      final success = await _cardService.updateCard(widget.cardId ?? '', updatedData);
      print('DEBUG: Update result for ${widget.cardId}: $success');
      print('DEBUG: Data sent: $updatedData');

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Изменения сохранены')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка при сохранении')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteCardDialog() {
    if (widget.cardId == null || widget.cardId!.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0C3135),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF557578), width: 1),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Вы точно хотите удалить визитку?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF557578)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Нет',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context); // Close dialog
                          setState(() => _isLoading = true);
                          final success = await _cardService.deleteCard(widget.cardId!);
                          if (mounted) {
                            setState(() => _isLoading = false);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Визитка удалена')),
                              );
                              Navigator.pop(context); // Return to previous screen
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ошибка при удалении')),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF334D50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Да, удалить',
                            style: TextStyle(
                              color: Color(0xFFFF8E30),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01191B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Редактирование визитки',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _showDeleteCardDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  // Header Card Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF0C3135),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70, height: 70,
                          decoration: const ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/70x70"),
                              fit: BoxFit.cover,
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.isNotEmpty ? _nameController.text : 'Имя',
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${_positionController.text} ${_companyController.text}',
                                style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                              ),
                              Text(
                                '$_selectedCategory • ${_directionController.text}',
                                style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  _buildSectionTitle('Основное'),
                  const SizedBox(height: 15),
                  _buildInputField('Название', _nameController),
                  _buildInputField('Должность / Профессия', _positionController),
                  _buildInputField('Компания', _companyController),
                  _buildSelectableField(
                    'Категория', 
                    _selectedCategory,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CategorySelectorSheet(
                          onCategorySelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    },
                  ),
                  _buildInputField('Направление деятельности', _directionController),
                  _buildInputField('Местоположение', _cityController),
                  
                  const SizedBox(height: 30),
                  _buildSectionTitle('Информация'),
                  const SizedBox(height: 15),
                  _buildLargeInputField('Введите описание', _descriptionController),
                  
                  const SizedBox(height: 30),
                  _buildSelectableField(
                    'Теги', 
                    _selectedTags.isEmpty ? 'Выберите теги' : _selectedTags.join(', '),
                    onTap: () {
                      TagSelectorSheet.show(
                        context,
                        initialTags: _selectedTags,
                        onSave: (tags) {
                          setState(() {
                            _selectedTags = tags;
                          });
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 30),
                  _buildSectionTitle('Контакты'),
                  const SizedBox(height: 15),
                  _buildInputField('Адрес работы', _addressController),
                  _buildSelectableField(
                    'Режим работы', 
                    _workMode.workDays.isEmpty
                        ? 'Выберите дни и часы'
                        : '${_workMode.workDays.length} дн. (${_workMode.startTime}-${_workMode.endTime})',
                    onTap: () {
                      WorkModeSheet.show(
                        context,
                        initialWorkMode: _workMode,
                        onSave: (newMode) {
                          setState(() {
                            _workMode = newMode;
                          });
                        },
                      );
                    },
                  ),
                  _buildInputField('Номер телефона', _phoneController),
                  _buildInputField('Почта', _emailController),
                  _buildInputField('Сайт', _websiteController),
                  _buildInputField('Телеграм', _telegramController),
                  _buildInputField('ВКонтакте', _vkController),
                  
                  const SizedBox(height: 40),
                  // Save Button
                  GestureDetector(
                    onTap: _isLoading ? null : _saveChanges,
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
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Сохранить изменения',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8E30)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFF8E30),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(color: Color(0xFF637B7E)),
              filled: true,
              fillColor: const Color(0xFF0C3135),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableField(String label, String value, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: const Color(0xFF0C3135),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value.isNotEmpty ? value : label,
                      style: TextStyle(
                        color: value.isNotEmpty ? Colors.white : const Color(0xFF637B7E),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF637B7E)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Описание...',
            hintStyle: const TextStyle(color: Color(0xFF637B7E)),
            filled: true,
            fillColor: const Color(0xFF0C3135),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF557578)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF557578)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF8E30)),
            ),
          ),
        ),
      ],
    );
  }
}
