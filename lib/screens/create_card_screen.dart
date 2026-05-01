import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_network/models/business_card_draft.dart';
import 'package:pro_network/services/business_card_service.dart';
import 'package:pro_network/services/post_service.dart';
import 'package:pro_network/screens/card_management_screen.dart';
import 'package:pro_network/widgets/app_text_field.dart';
import 'package:pro_network/widgets/business_card_preview.dart';
import 'package:pro_network/utils/constants.dart';
import 'package:pro_network/widgets/options_selector_sheet.dart';
import 'package:pro_network/data/categories_data.dart';
import 'package:pro_network/services/tag_service.dart';
import 'package:pro_network/widgets/work_mode_sheet.dart';
import 'package:pro_network/widgets/address_selector_sheet.dart';

class CreateCardScreen extends StatefulWidget {
  const CreateCardScreen({super.key});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final PageController _pageController = PageController();
  final BusinessCardDraft _draft = BusinessCardDraft();
  int _currentStep = 1;
  static const int _totalSteps = 9;
  final BusinessCardService _cardService = BusinessCardService();
  final PostService _postService = PostService();
  bool _isLoading = false;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TagService _tagService = TagService();
  List<String> _allTags = [];
  bool _isLoadingTags = true;
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();
  final TextEditingController _tgController = TextEditingController();
  final TextEditingController _vkController = TextEditingController();
  final TextEditingController _bookingController = TextEditingController();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _servicePriceController = TextEditingController();
  final TextEditingController _postDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await _tagService.getAllTags();
    if (mounted) {
      setState(() {
        _allTags = tags;
        _isLoadingTags = false;
      });
    }
  }

  void _nextStep() {
    // Explicitly update draft from controllers that use autocomplete
    if (_currentStep == 2) {
      _draft.city = _cityController.text;
    } else if (_currentStep == 7) {
      _draft.workAddress = _addressController.text;
    }

    if (_currentStep < _totalSteps) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Finalize creation
      Navigator.pop(context);
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildNameStep(),
                      _buildCityStep(),
                      _buildCategoryStep(),
                      _buildTagsStep(),
                      _buildPhotoStep(),
                      _buildDescriptionStep(),
                      _buildContactsStep(),
                      _buildPriceStep(),
                      _buildFinalStep(),
                    ],
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8E30)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: _prevStep,
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 4,
                        width: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C3135),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: Container(
                          height: 4,
                          width: (150 / _totalSteps) * _currentStep,
                          decoration: BoxDecoration(
                            color: const Color(0xFF557578),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '$_currentStep/$_totalSteps',
                style: const TextStyle(color: Color(0xFF637B7E), fontSize: 14),
              ),
              const SizedBox(width: 40), // Balance the back button
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepBase({required String title, String? subtitle, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF637B7E),
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 40),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return _buildStepBase(
      title: 'Название визитки',
      subtitle: 'Его видите только Вы',
      content: AppTextField(
        controller: _nameController,
        hintText: 'Введите название',
        onChanged: (val) => setState(() => _draft.name = val),
      ),
    );
  }

  Widget _buildCityStep() {
    return _buildStepBase(
      title: 'Где Вы работаете?',
      content: GestureDetector(
        onTap: () {
          AddressSelectorSheet.show(
            context,
            title: 'Город',
            initialValue: _cityController.text,
            onSelected: (val) {
              setState(() {
                _cityController.text = val;
                _draft.city = val;
              });
            },
          );
        },
        child: Container(
          width: double.infinity,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0C3135),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _cityController.text.isNotEmpty ? _cityController.text : 'Введите название города',
                style: TextStyle(
                  color: _cityController.text.isNotEmpty ? Colors.white : const Color(0xFF637B7E),
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF637B7E), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStep() {
    return _buildStepBase(
      title: 'Вид деятельности',
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildFieldLabel('Категория'),
            GestureDetector(
              onTap: _showCategoryPicker,
              child: Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3135),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _draft.category.isEmpty ? 'Выберите категорию' : _draft.category,
                      style: TextStyle(
                        color: _draft.category.isEmpty ? const Color(0xFF637B7E) : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF637B7E)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Направление деятельности'),
            GestureDetector(
              onTap: () {
                if (_draft.category.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Сначала выберите категорию')),
                  );
                  return;
                }
                OptionsSelectorSheet.show(
                  context,
                  title: 'Направление деятельности',
                  initialValue: _draft.activityDirection,
                  options: CategoriesData.getSubcategories(_draft.category),
                  onSelected: (val) {
                    setState(() {
                      _draft.activityDirection = val;
                      _directionController.text = val;
                    });
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3135),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _draft.activityDirection.isNotEmpty ? _draft.activityDirection : 'Выберите направление',
                      style: TextStyle(
                        color: _draft.activityDirection.isNotEmpty ? Colors.white : const Color(0xFF637B7E),
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF637B7E), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Профессия/должность'),
            AppTextField(
              controller: _positionController,
              hintText: 'Например: Генеральный директор',
              onChanged: (val) => setState(() => _draft.position = val),
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Название компании'),
            AppTextField(
              controller: _companyController,
              hintText: 'Например: Арматурис',
              onChanged: (val) => setState(() => _draft.company = val),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    OptionsSelectorSheet.show(
      context,
      title: 'Выберите категорию',
      initialValue: _draft.category,
      options: CategoriesData.categories,
      onSelected: (cat) {
        setState(() {
          if (_draft.category != cat) {
            _draft.category = cat;
            _draft.activityDirection = ''; // Reset on category change
            _directionController.clear();
          }
        });
      },
    );
  }

  String _tagSearchQuery = '';

  Widget _buildTagsStep() {
    final filteredTags = _allTags
        .where((tag) => tag.toLowerCase().contains(_tagSearchQuery.toLowerCase()) && !_draft.tags.contains(tag))
        .toList();

    final hasExactMatch = _allTags.any((tag) => tag.toLowerCase() == _tagSearchQuery.toLowerCase()) ||
                          _draft.tags.any((tag) => tag.toLowerCase() == _tagSearchQuery.toLowerCase());

    return _buildStepBase(
      title: 'Теги',
      subtitle: 'Выберите направление вашей деятельности',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              hintText: 'Поиск тегов',
              onChanged: (val) => setState(() => _tagSearchQuery = val),
            ),
            const SizedBox(height: 20),
            
            if (!hasExactMatch && _tagSearchQuery.isNotEmpty) ...[
              const Text('Новый тег', style: TextStyle(color: Color(0xFF637B7E), fontSize: 12)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_draft.tags.contains(_tagSearchQuery)) {
                      _draft.tags.add(_tagSearchQuery);
                    }
                    _tagSearchQuery = '';
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
                        'Создать тег: "$_tagSearchQuery"',
                        style: const TextStyle(color: Color(0xFFFF8E30), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (_draft.tags.isNotEmpty) ...[
              const Text('Выбранные теги', style: TextStyle(color: Color(0xFF637B7E), fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _draft.tags.map((tag) => _buildTagItem(tag, isSelected: true)).toList(),
              ),
              const SizedBox(height: 20),
            ],

            if (filteredTags.isNotEmpty) ...[
              const Text('Все теги', style: TextStyle(color: Color(0xFF637B7E), fontSize: 12)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredTags.map((tag) => _buildTagItem(tag, isSelected: false)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagItem(String tag, {required bool isSelected}) {
    final orangeColor = const Color(0xFFFF8E30);
    final greyColor = const Color(0xFFC6C6C6);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _draft.tags.remove(tag);
          } else {
            _draft.tags.add(tag);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 2 : 1,
              color: isSelected ? orangeColor : greyColor,
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
                color: isSelected ? orangeColor : greyColor,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 5),
              Icon(Icons.close, size: 12, color: orangeColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoStep() {
    return _buildStepBase(
      title: 'Фото визитки',
      content: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF0C3135),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _draft.photoPath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    image: kIsWeb 
                        ? NetworkImage(_draft.photoPath!) as ImageProvider
                        : FileImage(File(_draft.photoPath!)),
                    fit: BoxFit.cover,
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text('Добавить фото', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage({bool isPost = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isPost) {
          _draft.postPhotoFile = image;
        } else {
          _draft.photoFile = image;
        }
      });
    }
  }

  Widget _buildDescriptionStep() {
    return _buildStepBase(
      title: 'Введите описание',
      subtitle: 'Эту информацию увидят в визитке',
      content: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0C3135),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                maxLength: 500,
                onChanged: (val) {
                  setState(() => _draft.description = val);
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Помогаю оформить КАСКО...',
                  hintStyle: TextStyle(color: Color(0xFF637B7E)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Максимальное количество символов – 500',
                style: const TextStyle(color: Color(0xFF637B7E), fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Contact controllers are now at the top

  Widget _buildContactsStep() {
    return _buildStepBase(
      title: 'Контакты',
      subtitle: 'Эту информацию увидят в визитке',
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildFieldLabel('Адрес работы'),
            GestureDetector(
              onTap: () {
                AddressSelectorSheet.show(
                  context,
                  title: 'Адрес работы',
                  initialValue: _addressController.text,
                  onSelected: (val) {
                    setState(() {
                      _addressController.text = val;
                      _draft.workAddress = val;
                    });
                  },
                );
              },
              child: Container(
                width: double.infinity,
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3135),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _addressController.text.isNotEmpty ? _addressController.text : 'г. Москва, ул...',
                      style: TextStyle(
                        color: _addressController.text.isNotEmpty ? Colors.white : const Color(0xFF637B7E),
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF637B7E), size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Режим работы'),
            GestureDetector(
              onTap: () {
                WorkModeSheet.show(
                  context,
                  initialWorkMode: _draft.workMode,
                  onSave: (newMode) {
                    setState(() {
                      _draft.workMode = newMode;
                    });
                  },
                );
              },
              child: Container(
                height: 35,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3135),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _draft.workMode.workDays.isEmpty
                          ? 'Выберите дни и часы'
                          : '${_draft.workMode.workDays.length} дн. (${_draft.workMode.startTime}-${_draft.workMode.endTime})',
                      style: TextStyle(
                        color: _draft.workMode.workDays.isEmpty ? const Color(0xFF637B7E) : Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF637B7E)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Номер телефона'),
            AppTextField(
              controller: _phoneController,
              hintText: '+7 (999) 999 99 99',
              keyboardType: TextInputType.phone,
              onChanged: (val) => _draft.phone = val,
            ),
            _buildFieldSub('Не заполняйте, если хотите общаться только в чате'),
            const SizedBox(height: 15),
            _buildFieldLabel('Почта'),
            AppTextField(
              controller: _emailController,
              hintText: 'konstantin@armaturis.ru',
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) => _draft.email = val,
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Сайт'),
            AppTextField(
              controller: _siteController,
              hintText: 'armaturis.ru',
              onChanged: (val) => _draft.website = val,
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Телеграм'),
            AppTextField(
              controller: _tgController,
              hintText: '@armaturis',
              onChanged: (val) => _draft.telegram = val,
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('ВКонтакте'),
            AppTextField(
              controller: _vkController,
              hintText: 'armaturis.ru',
              onChanged: (val) => _draft.vk = val,
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Онлайн-запись'),
            AppTextField(
              controller: _bookingController,
              hintText: 'Вставьте ссылку',
              onChanged: (val) => _draft.onlineBookingUrl = val,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildFieldSub(String sub) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(sub, style: const TextStyle(color: Color(0xFF637B7E), fontSize: 12)),
      ),
    );
  }


  Widget _buildPriceStep() {
    return _buildStepBase(
      title: 'Прайс',
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (_draft.priceList.length < 10) ...[
              _buildFieldLabel('Услуга'),
              AppTextField(
                controller: _serviceNameController,
                hintText: 'Название услуги',
              ),
              const SizedBox(height: 15),
              _buildFieldLabel('Стоимость'),
              AppTextField(
                controller: _servicePriceController,
                hintText: 'Например: 15 000 руб.',
              ),
              const SizedBox(height: 15),
              Container(
                height: 40,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF334D50),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF557578)),
                ),
                child: InkWell(
                  onTap: () {
                    if (_serviceNameController.text.isNotEmpty && _servicePriceController.text.isNotEmpty) {
                      setState(() {
                        _draft.priceList.add({
                          'name': _serviceNameController.text,
                          'price': _servicePriceController.text,
                        });
                        _serviceNameController.clear();
                        _servicePriceController.clear();
                      });
                    }
                  },
                  child: const Center(
                    child: Text(
                      'Добавить',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Можно добавить до 10 услуг или товаров',
                style: TextStyle(color: Color(0xFF637B7E), fontSize: 12),
              ),
            ],
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _draft.priceList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _draft.priceList[index];
                return _buildPriceListItem(item['name']!, item['price']!, index);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceListItem(String name, String price, int index) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceItemPart('Услуга', name),
              const SizedBox(height: 10),
              _buildPriceItemPart('Стоимость', price),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _draft.priceList.removeAt(index);
                });
              },
              child: const Icon(Icons.close, color: Color(0xFF557578), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItemPart(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0C3135),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF557578)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalStep() {
    return _buildStepBase(
      title: 'Добавьте первый пост в своей визитке',
      subtitle: 'Расскажите о своей деятельности, покажите фото своих работ, создайте портфолио в постах визитки',
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Post Media Placeholder
            GestureDetector(
              onTap: () => _pickImage(isPost: true),
              child: Container(
                width: double.infinity,
                height: 266,
                decoration: BoxDecoration(
                  color: const Color(0xFF334D50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _draft.postPhotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: kIsWeb 
                              ? NetworkImage(_draft.postPhotoPath!) as ImageProvider
                              : FileImage(File(_draft.postPhotoPath!)),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.add_a_photo, color: Colors.white, size: 50),
                      ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Reusable User Card Preview
            BusinessCardPreview(draft: _draft),
            const SizedBox(height: 15),

            // Post Description Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0C3135),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF557578)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _postDescriptionController,
                    maxLines: null,
                    maxLength: 500,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    onChanged: (val) => setState(() => _draft.postDescription = val),
                    decoration: const InputDecoration(
                      hintText: 'Вот примеры моих работ...',
                      hintStyle: TextStyle(color: Color(0xFF637B7E)),
                      border: InputBorder.none,
                      counterText: '',
                      filled: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  'Максимальное количество символов – 500',
                  style: TextStyle(color: Color(0xFFC6C6C6), fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _onPublish({bool withPost = true}) async {
    setState(() => _isLoading = true);
    
    // If not publishing with post, clear the post-specific data
    if (!withPost) {
      _draft.postPhotoFile = null;
      _draft.postDescription = '';
    }
    
    final cardId = await _cardService.createBusinessCard(_draft);
    
    if (cardId != null && withPost && _draft.postPhotoFile != null) {
      // Create a news post attached to this card
      await _postService.createPost(
        _draft.postPhotoFile!,
        _draft.postDescription,
        postType: 'news',
        cardId: cardId,
      );
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (cardId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(withPost && _draft.postPhotoFile != null ? 'Визитка и пост успешно опубликованы!' : 'Визитка успешно создана!')),
        );
        // Navigate to management screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CardManagementScreen()),
          (route) => route.isFirst, // Go back to main and then to card management
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при публикации. Попробуйте еще раз.')),
        );
      }
    }
  }

  bool _canContinue() {
    if (_currentStep == 1) return _draft.name.isNotEmpty;
    if (_currentStep == 2) return _draft.city.isNotEmpty;
    if (_currentStep == 3) {
      return _draft.category.isNotEmpty && 
             _draft.activityDirection.isNotEmpty && 
             _draft.position.isNotEmpty;
    }
    if (_currentStep == 4) return _draft.tags.isNotEmpty;
    return true; // steps 5-9 are optional
  }

  Widget _buildBottomBar() {
    final bool canNext = _canContinue();
    final bool showSkip = _currentStep >= 5 && _currentStep < 9;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: canNext ? const Color(0xFF334D50) : const Color(0xFF1B2F31),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: canNext ? const Color(0xFF557578) : const Color(0xFF2A4244)),
            ),
            child: InkWell(
              onTap: canNext 
                ? (_currentStep == _totalSteps 
                    ? (_draft.postPhotoFile != null ? _onPublish : null) 
                    : _nextStep) 
                : null,
              child: Center(
                child: Text(
                  _currentStep == _totalSteps ? 'Опубликовать' : 'Далее',
                  style: TextStyle(
                    color: canNext 
                        ? (_currentStep == _totalSteps && _draft.postPhotoFile == null ? const Color(0xFF557578) : Colors.white)
                        : const Color(0xFF557578),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (showSkip || _currentStep == _totalSteps) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _currentStep == _totalSteps ? () => _onPublish(withPost: false) : _nextStep,
              child: Container(
              width: double.infinity,
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF557578),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
                child: Center(
                  child: Text(
                    _currentStep == _totalSteps ? 'Создать визитку без поста' : 'Пропустить',
                    style: const TextStyle(
                      color: Color(0xFF557578),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ),
            ),
          ],
        ],
      ),
    );
  }
}
