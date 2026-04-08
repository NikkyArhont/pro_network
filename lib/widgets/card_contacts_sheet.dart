import 'package:flutter/material.dart';
import 'package:pro_network/models/business_card_draft.dart';
import 'package:url_launcher/url_launcher.dart';

class CardContactsSheet extends StatelessWidget {
  final BusinessCardDraft card;

  const CardContactsSheet({super.key, required this.card});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            // Header
            Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Контакты',
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

            // Address
            if (card.workAddress.isNotEmpty)
              _buildContactItem('Адрес', card.workAddress),

            // Work Mode
            if (card.workMode.workDays.isNotEmpty)
              _buildWorkMode(),

            // Phone
            if (card.phone.isNotEmpty)
              _buildContactItem('Номер телефона', card.phone, onTap: () => _launchUrl('tel:${card.phone}')),

            // Email
            if (card.email.isNotEmpty)
              _buildContactItem('Почта', card.email, onTap: () => _launchUrl('mailto:${card.email}')),

            // Website
            if (card.website.isNotEmpty)
              _buildContactItem('Сайт', card.website, isLink: true, onTap: () => _launchUrl(card.website)),

            // Telegram
            if (card.telegram.isNotEmpty)
              _buildContactItem('Телеграм', card.telegram, onTap: () {
                final handle = card.telegram.replaceAll('@', '');
                _launchUrl('https://t.me/$handle');
              }),

            // VK
            if (card.vk.isNotEmpty)
              _buildContactItem('ВКонтакте', card.vk, isLink: true, onTap: () => _launchUrl(card.vk)),

            // Online Booking
            if (card.onlineBookingUrl.isNotEmpty)
              _buildContactItem('Онлайн-запись', card.onlineBookingUrl, isLink: true, onTap: () => _launchUrl(card.onlineBookingUrl)),
            
            // Bottom Bar Indicator
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
      ),
    );
  }

  Widget _buildContactItem(String label, String value, {bool isLink = false, VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF8E30),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
              letterSpacing: 0.15,
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkMode() {
    final allDays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const Text(
            'Режим работы',
            style: TextStyle(
              color: Color(0xFFFF8E30),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.50,
              letterSpacing: 0.15,
            ),
          ),
          ...allDays.map((day) {
            final isWorkDay = card.workMode.workDays.contains(day);
            return Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Text(
                  isWorkDay ? '${card.workMode.startTime} - ${card.workMode.endTime}' : 'выходной',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
