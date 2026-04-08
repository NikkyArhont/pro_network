import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_network/models/business_card_draft.dart';
import 'package:pro_network/services/business_card_service.dart';
import 'package:pro_network/widgets/app_text_field.dart';
import 'package:pro_network/widgets/business_card_preview.dart';

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
  bool _isLoading = false;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _directionController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
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

  void _nextStep() {
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
      content: AppTextField(
        controller: _cityController,
        hintText: 'Введите название города',
        onChanged: (val) => setState(() => _draft.city = val),
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
            AppTextField(
              controller: _directionController,
              hintText: 'Например: Страхование',
              onChanged: (val) => setState(() => _draft.activityDirection = val),
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
    final categories = ['Услуги', 'Торговля', 'Производство', 'Инвестиции'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF01191B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((cat) {
              return ListTile(
                title: Text(cat, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _draft.category = cat;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  static const List<String> _allTags = [
    'КАСКО', 'ОСАГО', 'ДМС', 'Страхование имущества', 'Страхование жизни',
    'Юридическая помощь', 'Оценка ущерба', 'Консультация', 'Ремонт авто', 'Техосмотр'
  ];
  String _tagSearchQuery = '';

  Widget _buildTagsStep() {
    final filteredTags = _allTags
        .where((tag) => tag.toLowerCase().contains(_tagSearchQuery.toLowerCase()) && !_draft.tags.contains(tag))
        .toList();

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

            const Text('Все теги', style: TextStyle(color: Color(0xFF637B7E), fontSize: 12)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredTags.map((tag) => _buildTagItem(tag, isSelected: false)).toList(),
            ),
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
            AppTextField(
              controller: _addressController,
              hintText: 'г. Москва, ул...',
              onChanged: (val) => _draft.workAddress = val,
            ),
            const SizedBox(height: 15),
            _buildFieldLabel('Режим работы'),
            GestureDetector(
              onTap: _showWorkModePicker,
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

  void _showWorkModePicker() {
    final days = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    final startCtrl = TextEditingController(text: _draft.workMode.startTime);
    final endCtrl = TextEditingController(text: _draft.workMode.endTime);
    List<String> selectedDays = List.from(_draft.workMode.workDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF01191B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Режим работы', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft, child: Text('Часы', style: TextStyle(color: Color(0xFFFF8E30), fontSize: 14))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeInput(startCtrl, '10:00'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTimeInput(endCtrl, '19:00'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Align(alignment: Alignment.centerLeft, child: Text('Дни недели', style: TextStyle(color: Color(0xFFFF8E30), fontSize: 14))),
                  const SizedBox(height: 10),
                  ...days.map((day) {
                    final isSelected = selectedDays.contains(day);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setModalState(() {
                            if (isSelected) {
                              selectedDays.remove(day);
                            } else {
                              selectedDays.add(day);
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
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.10,
                                      ),
                                    ),
                                    Container(
                                      width: 15,
                                      height: 15,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF334D50), borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _draft.workMode.startTime = startCtrl.text;
                          _draft.workMode.endTime = endCtrl.text;
                          _draft.workMode.workDays = selectedDays;
                        });
                        Navigator.pop(context);
                      },
                      child: const Center(child: Text('Сохранить', style: TextStyle(color: Colors.white))),
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
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.datetime,
        ),
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
    
    final success = await _cardService.createBusinessCard(_draft);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Визитка и пост успешно опубликованы!')),
        );
        Navigator.pop(context);
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
              child: const Center(
                child: Text(
                  'Пропустить',
                  style: TextStyle(
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
