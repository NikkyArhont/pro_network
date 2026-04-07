import 'package:flutter/material.dart';
import 'package:pro_network/screens/phone_auth_screen.dart';

class ProfileFillScreen extends StatefulWidget {
  const ProfileFillScreen({super.key});

  @override
  State<ProfileFillScreen> createState() => _ProfileFillScreenState();
}

class _ProfileFillScreenState extends State<ProfileFillScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _photoController = TextEditingController();
  bool _agreed = false;

  void _continue() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите имя')),
      );
      return;
    }
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Необходимо принять условия')),
      );
      return;
    }
    
    final profileData = {
      'name': _nameController.text.trim(),
      'city': _cityController.text.trim(),
      'photoUrl': _photoController.text.trim(),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneAuthScreen(
          isLogin: false,
          profileData: profileData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создание профиля')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Расскажите о себе',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Имя и Фамилия'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'Город'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _photoController,
              decoration: const InputDecoration(labelText: 'URL фотографии (опционально)'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (val) => setState(() => _agreed = val ?? false),
                  activeColor: Colors.blueAccent,
                ),
                const Expanded(
                  child: Text(
                    'Я соглашаюсь с политикой конфиденциальности',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _continue,
              child: const Text('Продолжить'),
            ),
          ],
        ),
      ),
    );
  }
}

