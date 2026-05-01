import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pro_network/models/notification_model.dart';
import 'package:pro_network/services/notification_service.dart';
import 'package:pro_network/services/user_service.dart';
import 'package:pro_network/services/contact_service.dart';
import 'package:pro_network/services/environment_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pro_network/widgets/app_text_field.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final ContactService _contactService = ContactService();
  final EnvironmentService _environmentService = EnvironmentService();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<ContactMatch> _matchedContacts = [];
  bool _isLoadingContacts = false;
  bool _hasPermission = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
  }

  Future<void> _checkPermissionAndLoad() async {
    setState(() => _isLoadingContacts = true);
    final granted = await _contactService.requestPermission();
    setState(() => _hasPermission = granted);
    if (granted) {
      final matches = await _contactService.getMatchedContacts();
      setState(() => _matchedContacts = matches);
      
      // Sync contacts for the Environment feature
      final registeredUids = matches
          .where((m) => m.isRegistered && m.appUser != null && m.appUser!['uid'] != null)
          .map((m) => m.appUser!['uid'] as String)
          .toList();
      if (registeredUids.isNotEmpty) {
        await _environmentService.syncContacts(_currentUserId, registeredUids);
      }
    }
    setState(() => _isLoadingContacts = false);
  }

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
          'СВЯЗИ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Search Field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AppTextField(
                controller: _searchController,
                hintText: 'Поиск контактов...',
                prefix: const Icon(Icons.search, color: Color(0xFF637B7E), size: 18),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
          ),
          // Section: Notifications/Requests (Real-time)
          SliverToBoxAdapter(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.getNotificationsStream(_currentUserId),
              builder: (context, snapshot) {
                final notifications = snapshot.data ?? [];
                final connectionNotifs = notifications.where((n) => 
                  n.type == NotificationType.request || 
                  n.type == NotificationType.connectionAdded || 
                  n.type == NotificationType.recommendation ||
                  n.type == NotificationType.birthday
                ).toList();

                if (connectionNotifs.isEmpty) return const SizedBox.shrink();

                final birthdays = connectionNotifs.where((n) => n.type == NotificationType.birthday).toList();
                final requests = connectionNotifs.where((n) => n.type == NotificationType.request).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (birthdays.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionTitle('Дни рождения'),
                        ...birthdays.map((n) => _buildNotificationItem(n)),
                      ],
                      if (requests.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionTitle('Заявки'),
                        ...requests.map((n) => _buildNotificationItem(n)),
                      ],
                      const SizedBox(height: 20),
                      _buildDivider(),
                    ],
                  ),
                );
              },
            ),
          ),

          // Section: Phone Contacts
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSectionTitle('Контакты из телефона'),
                  if (!_hasPermission)
                    _buildPermissionRequest()
                  else if (_isLoadingContacts)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFFF8E30))),
                    )
                  else if (_matchedContacts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Контакты не найдены', style: TextStyle(color: Color(0xFFC6C6C6))),
                    ),
                ],
              ),
            ),
          ),

          if (_hasPermission && !_isLoadingContacts) ...[
            // Registered users from contacts
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final registered = _matchedContacts
                      .where((m) => m.isRegistered)
                      .where((m) {
                        final name = (m.appUser?['displayName'] ?? m.contact.displayName).toString().toLowerCase();
                        return name.contains(_searchQuery.toLowerCase());
                      })
                      .toList();
                  if (index >= registered.length) return null;
                  return _buildContactItem(registered[index]);
                },
                childCount: _matchedContacts
                    .where((m) => m.isRegistered)
                    .where((m) {
                      final name = (m.appUser?['displayName'] ?? m.contact.displayName).toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase());
                    })
                    .length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            
            // Unregistered users
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  _searchQuery.isEmpty ? 'Пригласить в приложение' : 'Другие совпадения',
                  style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final unregistered = _matchedContacts
                      .where((m) => !m.isRegistered)
                      .where((m) {
                        final name = (m.contact.displayName ?? '').toLowerCase();
                        return name.contains(_searchQuery.toLowerCase());
                      })
                      .toList();
                  if (index >= unregistered.length) return null;
                  return _buildContactItem(unregistered[index]);
                },
                childCount: _matchedContacts
                    .where((m) => !m.isRegistered)
                    .where((m) {
                      final name = (m.contact.displayName ?? '').toLowerCase();
                      return name.contains(_searchQuery.toLowerCase());
                    })
                    .length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
        letterSpacing: 0.15,
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3135),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text(
            'Синхронизируйте контакты, чтобы найти друзей в приложении',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _checkPermissionAndLoad,
            child: _buildActionButton('Синхронизировать', isPrimary: true),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(ContactMatch match) {
    final String name = match.isRegistered 
        ? (match.appUser?['displayName'] ?? match.contact.displayName)
        : match.contact.displayName;
    final String? photoUrl = match.isRegistered && match.appUser != null 
        ? match.appUser!['photoUrl'] as String? 
        : null;
    final String phone = match.contact.phones.isNotEmpty ? match.contact.phones.first.number : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          _buildAvatar(photoUrl ?? '', name),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                Text(phone, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
              ],
            ),
          ),
          if (match.isRegistered)
            GestureDetector(
              onTap: () {
                // Logic to follow or message
                _userService.toggleSubscription(_currentUserId, match.appUser!['uid']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Вы подписались на $name')),
                );
              },
              child: _buildActionButton('Добавить', isPrimary: true),
            )
          else
            GestureDetector(
              onTap: () async {
                final url = 'sms:$phone?body=Привет! Присоединяйся ко мне в приложении PROnetwork.';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: _buildActionButton('Пригласить', isPrimary: false),
            ),
        ],
      ),
    );
  }

  // Reuse the UI helpers from before
  Widget _buildNotificationItem(NotificationModel notification) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userService.getUserData(notification.fromUserId ?? ''),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final name = userData?['displayName'] ?? 'Пользователь';
        final photoUrl = userData?['photoUrl'] ?? '';
        final position = userData?['position'] ?? '';

        if (notification.type == NotificationType.birthday) {
          return _buildBirthdayUI(name, photoUrl);
        } else if (notification.type == NotificationType.request) {
          return _buildRequestUI(notification, name, photoUrl, position);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBirthdayUI(String name, String photoUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildAvatar(photoUrl, name),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const Text('Сегодня день рождения', style: TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
              ],
            ),
          ),
          _buildActionButton('Поздравить', isPrimary: true),
        ],
      ),
    );
  }

  Widget _buildRequestUI(NotificationModel n, String name, String photoUrl, String position) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          _buildAvatar(photoUrl, name),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                Text(position, style: const TextStyle(color: Color(0xFFC6C6C6), fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(onTap: () => _notificationService.markAsRead(n.id), child: const Icon(Icons.check_circle, color: Colors.green, size: 24)),
              const SizedBox(width: 10),
              GestureDetector(onTap: () => _notificationService.deleteNotification(n.id), child: const Icon(Icons.cancel, color: Colors.red, size: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String photoUrl, String name) {
    return Container(
      width: 45,
      height: 45,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: isPrimary ? const Color(0xFF334D50) : null,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF557578)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF557578), fontSize: 13),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFC6C6C6).withOpacity(0.3));
  }
}
