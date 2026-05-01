import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Состояния для тумблеров
  bool _soundsEnabled = false;
  bool _vibrationEnabled = true;
  bool _showTextEnabled = true;
  bool _connectionsEnabled = true;
  bool _reactionsEnabled = true;
  bool _followersEnabled = true;
  bool _postsEnabled = true;
  bool _newsEnabled = false;
  bool _offersEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01191B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Настройки уведомлений',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        children: [
          _buildSectionTitle('Основные'),
          const SizedBox(height: 8),
          _buildRoundedContainer([
            _buildSwitchItem('Звуки', _soundsEnabled, (val) => setState(() => _soundsEnabled = val)),
            _buildDivider(),
            _buildSwitchItem('Вибрация', _vibrationEnabled, (val) => setState(() => _vibrationEnabled = val)),
            _buildDivider(),
            _buildSwitchItem('Показывать текст', _showTextEnabled, (val) => setState(() => _showTextEnabled = val)),
          ]),
          const SizedBox(height: 30),
          _buildSectionTitle('Пуши'),
          const SizedBox(height: 8),
          _buildRoundedContainer([
            _buildSwitchItem('Заявки в СВЯЗИ', _connectionsEnabled, (val) => setState(() => _connectionsEnabled = val)),
            _buildDivider(),
            _buildSwitchItem('Реакции', _reactionsEnabled, (val) => setState(() => _reactionsEnabled = val)),
            _buildDivider(),
            _buildSwitchItem('Новые подписчики', _followersEnabled, (val) => setState(() => _followersEnabled = val)),
            _buildDivider(),
            _buildSwitchItem('Посты', _postsEnabled, (val) => setState(() => _postsEnabled = val)),
            _buildDivider(),
            _buildSwitchItem('Новости', _newsEnabled, (val) => setState(() => _newsEnabled = val)),
            _buildDivider(),
            _buildSwitchItem('Предложения', _offersEnabled, (val) => setState(() => _offersEnabled = val)),
          ]),
          const SizedBox(height: 30),
          _buildResetButton(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _soundsEnabled = false;
      _vibrationEnabled = true;
      _showTextEnabled = true;
      _connectionsEnabled = true;
      _reactionsEnabled = true;
      _followersEnabled = true;
      _postsEnabled = true;
      _newsEnabled = false;
      _offersEnabled = false;
    });
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _resetSettings,
      child: Container(
        width: double.infinity,
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFF557578)),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Сбросить настройки уведомлений',
          style: TextStyle(
            color: Color(0xFF557578),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFF8E30),
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildRoundedContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchItem(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF8E30),
            activeTrackColor: const Color(0xFF3F5659),
            inactiveThumbColor: const Color(0xFF7C9597),
            inactiveTrackColor: const Color(0xFF3F5659),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFF01191B).withOpacity(0.5),
      indent: 20,
      endIndent: 20,
    );
  }
}
