import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/models/notification_model.dart';
import 'package:pro_network/services/notification_service.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

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
          'Уведомления',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _notificationService.getNotificationsStream(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30)));
          }
          
          final notifications = snapshot.data ?? [];
          
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'У вас пока нет уведомлений',
                style: TextStyle(color: Color(0xFFC6C6C6), fontSize: 14),
              ),
            );
          }

          // Grouping notifications
          final birthdays = notifications.where((n) => n.type == NotificationType.birthday).toList();
          final requests = notifications.where((n) => n.type == NotificationType.request).toList();
          final connections = notifications.where((n) => n.type == NotificationType.connectionAdded).toList();
          final recommendations = notifications.where((n) => n.type == NotificationType.recommendation).toList();
          final systems = notifications.where((n) => n.type == NotificationType.system).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: [
              if (birthdays.isNotEmpty) ...[
                _buildSectionTitle('Дни рождения'),
                const SizedBox(height: 15),
                ...birthdays.map((n) => _buildNotificationItem(n)),
                const SizedBox(height: 15),
                _buildDivider(),
                const SizedBox(height: 15),
              ],
              
              if (requests.isNotEmpty) ...[
                _buildSectionTitle('Заявки'),
                const SizedBox(height: 15),
                ...requests.map((n) => _buildNotificationItem(n)),
                const SizedBox(height: 15),
                _buildDivider(),
                const SizedBox(height: 15),
              ],

              if (connections.isNotEmpty) ...[
                _buildSectionTitle('СВЯЗИ'),
                const SizedBox(height: 15),
                ...connections.map((n) => _buildNotificationItem(n)),
                const SizedBox(height: 15),
                _buildDivider(),
                const SizedBox(height: 15),
              ],
              
              if (recommendations.isNotEmpty) ...[
                _buildSectionTitle('Рекомендации'),
                const SizedBox(height: 15),
                ...recommendations.map((n) => _buildNotificationItem(n)),
                const SizedBox(height: 15),
                _buildDivider(),
                const SizedBox(height: 15),
              ],
              
              if (systems.isNotEmpty) ...[
                _buildSectionTitle('Системные оповещения'),
                const SizedBox(height: 15),
                ...systems.map((n) => _buildNotificationItem(n)),
                const SizedBox(height: 15),
                _buildDivider(),
                const SizedBox(height: 15),
              ],
              
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w500,
        height: 1.50,
        letterSpacing: 0.15,
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    if (notification.fromUserId != null) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: _userService.getUserData(notification.fromUserId!),
        builder: (context, snapshot) {
          final userData = snapshot.data;
          final name = userData?['displayName'] ?? 'Пользователь';
          final photoUrl = userData?['photoUrl'] ?? '';
          final position = userData?['position'] ?? '';
          final category = userData?['category'] ?? '';
          final activity = userData?['activity'] ?? '';
          final combinedCategory = '${category}${category.isNotEmpty && activity.isNotEmpty ? ' • ' : ''}${activity}';

          switch (notification.type) {
            case NotificationType.birthday:
              return _buildBirthdayItem(
                name: name,
                time: _formatTime(notification.createdAt),
                imageUrl: photoUrl,
              );
            case NotificationType.request:
              return _buildRequestItem(
                name: name,
                time: _formatTime(notification.createdAt),
                position: position,
                imageUrl: photoUrl,
                onAccept: () => _notificationService.markAsRead(notification.id),
                onDecline: () => _notificationService.deleteNotification(notification.id),
              );
            case NotificationType.connectionAdded:
              return _buildConnectionItem(
                name: name,
                time: _formatTime(notification.createdAt),
                position: position,
                category: combinedCategory,
                imageUrl: photoUrl,
                message: notification.body,
              );
            case NotificationType.recommendation:
              return _buildRecommendationItem(
                name: name,
                time: _formatTime(notification.createdAt),
                position: position,
                category: combinedCategory,
                imageUrl: photoUrl,
              );
            default:
              return _buildSystemAlert(
                title: notification.title,
                time: _formatTime(notification.createdAt),
                message: notification.body,
              );
          }
        },
      );
    } else {
      return _buildSystemAlert(
        title: notification.title,
        time: _formatTime(notification.createdAt),
        message: notification.body,
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} м';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} д';
    } else {
      return '${(difference.inDays / 7).floor()} н';
    }
  }

  Widget _buildBirthdayItem({required String name, required String time, required String imageUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(imageUrl, name),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const Text('Сегодня празднует день рождения', style: TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
                const SizedBox(height: 10),
                _buildActionButton('Поздравить в чате', isPrimary: true),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildRequestItem({
    required String name, 
    required String time, 
    required String position, 
    required String imageUrl,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(imageUrl, name),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                Text(position, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAccept,
                      child: _buildActionButton('Принять', isPrimary: true),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: onDecline,
                      child: _buildActionButton('Отклонить', isPrimary: false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildConnectionItem({required String name, required String time, required String position, required String category, required String imageUrl, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(imageUrl, name),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                if (position.isNotEmpty) Text(position, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
                if (category.isNotEmpty) Text(category, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
                const SizedBox(height: 5),
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({required String name, required String time, required String position, required String category, required String imageUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(imageUrl, name),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                if (position.isNotEmpty) Text(position, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
                if (category.isNotEmpty) Text(category, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
                const SizedBox(height: 5),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'У Тебя новая ', style: TextStyle(color: Colors.white, fontSize: 12)),
                      TextSpan(text: 'Рекомендация!', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSystemAlert({required String title, required String time, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF0C3135),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: Color(0xFFFF8E30), size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                Text(message, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAvatar(String photoUrl, String name) {
    return Container(
      width: 50,
      height: 50,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: photoUrl.isNotEmpty 
              ? NetworkImage(photoUrl) 
              : NetworkImage("https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random") as ImageProvider,
          fit: BoxFit.cover,
        ),
        shape: const OvalBorder(),
      ),
    );
  }

  Widget _buildActionButton(String text, {required bool isPrimary}) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: isPrimary ? const Color(0xFF334D50) : null,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF557578)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: isPrimary ? Colors.white : const Color(0xFF557578),
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          letterSpacing: 0.10,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            strokeAlign: BorderSide.strokeAlignCenter,
            color: Color(0xFFC6C6C6),
          ),
        ),
      ),
    );
  }
}
