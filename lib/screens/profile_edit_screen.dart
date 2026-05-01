import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/utils/constants.dart';
import 'package:pro_network/widgets/options_selector_sheet.dart';
import 'package:pro_network/data/categories_data.dart';
import 'package:pro_network/widgets/address_selector_sheet.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final UserService _userService = UserService();
  final _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  
  String _photoUrl = '';
  String _selectedStatus = 'Выберите статус';
  String _selectedGender = 'Выберите пол';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final data = await _userService.getUserData(user.uid);
      if (data != null) {
        setState(() {
          final displayName = data['displayName'] ?? '';
          final names = displayName.split(' ');
          _firstNameController.text = names.isNotEmpty ? names[0] : '';
          _lastNameController.text = names.length > 1 ? names.sublist(1).join(' ') : '';
          
          _cityController.text = data['city'] ?? '';
          _photoUrl = data['photoUrl'] ?? '';
          _selectedStatus = data['status'] ?? 'Выберите статус';
          _selectedGender = data['gender'] ?? 'Выберите пол';
          
          _birthDateController.text = data['birthDate'] ?? '';
          _positionController.text = data['position'] ?? '';
          _companyController.text = data['company'] ?? '';
          _categoryController.text = data['category'] ?? '';
          _activityController.text = data['activity'] ?? '';
          
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        final user = _auth.currentUser;
        if (user != null) {
          final newUrl = await _userService.uploadAvatar(user.uid, image);
          if (newUrl != null) {
            setState(() {
              _photoUrl = newUrl;
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе фото: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEmploymentStatusSheet() {
    final List<String> statuses = [
      'В найме',
      'Владелец',
      'Работаю на себя',
      'Временно не работаю',
      'Студент',
      'Пенсионер'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 30),
              decoration: const ShapeDecoration(
                color: Color(0xFF11292B),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Color(0xFF0C3135)),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                shadows: [BoxShadow(color: Color(0xCC000000), blurRadius: 20, offset: Offset(0, -20))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Статус занятости',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: statuses.map((status) {
                      final isSelected = _selectedStatus == status;
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() => _selectedStatus = status);
                          setState(() {});
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
                            status,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFFF8E30) : const Color(0xFFC6C6C6),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 35,
                      padding: const EdgeInsets.all(10),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF334D50),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFF557578)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGenderSheet() {
    final List<String> genders = ['Мужской', 'Женский'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 30),
          decoration: const ShapeDecoration(
            color: Color(0xFF11292B),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: Color(0xFF0C3135)),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Выберите пол', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              ...genders.map((gender) => ListTile(
                title: Text(gender, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _selectedGender = gender);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showCategorySheet() {
    OptionsSelectorSheet.show(
      context,
      title: 'Выберите категорию',
      initialValue: _categoryController.text,
      options: CategoriesData.categories,
      onSelected: (category) {
        setState(() {
          if (_categoryController.text != category) {
            _categoryController.text = category;
            _activityController.clear(); // Reset on change
          }
        });
      },
    );
  }

  void _showDeleteAccountDialog() {
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
                  'Вы точно хотите удалить аккаунт?',
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
                        onTap: () {
                          // TODO: Implement actual deletion logic
                          print('Account deletion requested');
                          Navigator.pop(context);
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

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _userService.updateUserProfile(
          uid: user.uid,
          data: {
            'displayName': '${_firstNameController.text} ${_lastNameController.text}'.trim(),
            'city': _cityController.text,
            'birthDate': _birthDateController.text,
            'status': _selectedStatus,
            'gender': _selectedGender,
            'position': _positionController.text,
            'company': _companyController.text,
            'category': _categoryController.text,
            'activity': _activityController.text,
            'photoUrl': _photoUrl,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Профиль успешно обновлен')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF01191B),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Редактирование профиля',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showDeleteAccountDialog,
                    child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF0C3135), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : const NetworkImage("https://ui-avatars.com/api/?name=User&size=70&background=283F41&color=fff"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0, top: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 20, height: 20,
                                    decoration: BoxDecoration(color: const Color(0xFFFF8E30), borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_firstNameController.text}\n${_lastNameController.text}',
                                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400, height: 1.33),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.business_center_outlined, size: 15, color: Color(0xFFC6C6C6)),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        '${_positionController.text} ${_companyController.text}',
                                        style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  _categoryController.text.isNotEmpty ? _categoryController.text : 'Категория не указана',
                                  style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildField('Имя', _firstNameController),
                    _buildField('Фамилия', _lastNameController),
                    _buildField('Дата рождения', _birthDateController, hint: '__.__.____'),
                    _buildField('Пол', TextEditingController(text: _selectedGender), isDropdown: true, onTap: _showGenderSheet),
                    _buildField('Город', _cityController, isAddress: true),
                    _buildField('Статус занятости', TextEditingController(text: _selectedStatus), isDropdown: true, onTap: _showEmploymentStatusSheet),
                    _buildField('Должность', _positionController),
                    _buildField('Компания', _companyController),
                    _buildField('Категория', _categoryController, isDropdown: true, onTap: _showCategorySheet),
                    const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Направление деятельности', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          _activityController, 
                          isDropdown: true,
                          onTap: () {
                            if (_categoryController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Сначала выберите категорию')),
                              );
                              return;
                            }
                            OptionsSelectorSheet.show(
                              context,
                              title: 'Направление деятельности',
                              initialValue: _activityController.text,
                              options: CategoriesData.getSubcategories(_categoryController.text),
                              onSelected: (val) {
                                setState(() {
                                  _activityController.text = val;
                                });
                              },
                            );
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Text(
                            'Можно менять не чаще одного раза в месяц. Сможете поменять 12.02.2026',
                            style: TextStyle(color: Color(0xFFC6C6C6), fontSize: 12, height: 1.33),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _saveProfile,
                      child: Container(
                        width: double.infinity, height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334D50),
                          border: Border.all(color: const Color(0xFF557578)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint, bool isDropdown = false, bool isLocked = false, bool isAddress = false, VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(height: 8),
        if (isAddress)
          _buildInputField(
            controller,
            hint: hint,
            isDropdown: true,
            onTap: () {
              AddressSelectorSheet.show(
                context,
                title: label,
                initialValue: controller.text,
                onSelected: (val) {
                  setState(() {
                    controller.text = val;
                  });
                },
              );
            },
          )
        else
          _buildInputField(controller, hint: hint, isDropdown: isDropdown, isLocked: isLocked, onTap: onTap),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, {String? hint, bool isDropdown = false, bool isLocked = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0C3135),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.centerLeft,
        child: isDropdown || isLocked
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      controller.text.isEmpty ? (hint ?? '') : controller.text,
                      style: TextStyle(color: isLocked ? const Color(0xFF637B7E) : Colors.white, fontSize: 14),
                    ),
                  ),
                  if (isDropdown) const Icon(Icons.keyboard_arrow_down, color: Color(0xFFC6C6C6), size: 20),
                ],
              )
            : TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Color(0xFFC6C6C6)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.transparent,
                ),
              ),
      ),
    );
  }
}
