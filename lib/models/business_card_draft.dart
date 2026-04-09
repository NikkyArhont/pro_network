import 'package:image_picker/image_picker.dart';

class BusinessCardDraft {
  String name = '';
  String city = '';
  String category = '';
  String activityDirection = '';
  String position = '';
  String company = '';
  List<String> tags = [];
  XFile? photoFile;
  String description = '';
  
  // Activation
  bool isActive = false;
  dynamic activeUntil; // Timestamp or null
  
  // Contacts
  String status = '';
  String workAddress = '';
  WorkMode workMode = WorkMode();
  String phone = '';
  String email = '';
  String website = '';
  String telegram = '';
  String vk = '';
  String onlineBookingUrl = '';
  
  List<Map<String, String>> priceList = [];
  
  // First Post
  XFile? postPhotoFile;
  String postDescription = '';

  BusinessCardDraft();

  String? get photoPath => photoFile?.path;
  String? get postPhotoPath => postPhotoFile?.path;

  factory BusinessCardDraft.fromMap(Map<String, dynamic> map) {
    var draft = BusinessCardDraft();
    draft.name = map['name'] ?? '';
    draft.city = map['city'] ?? '';
    draft.category = map['category'] ?? '';
    draft.activityDirection = map['activityDirection'] ?? '';
    draft.position = map['position'] ?? '';
    draft.company = map['company'] ?? '';
    draft.tags = List<String>.from(map['tags'] ?? []);
    draft.description = map['description'] ?? '';
    draft.isActive = map['isActive'] ?? false;
    draft.activeUntil = map['activeUntil'];
    draft.workAddress = map['address'] ?? '';
    draft.phone = map['phone'] ?? '';
    draft.email = map['email'] ?? '';
    draft.website = map['website'] ?? '';
    draft.telegram = map['telegram'] ?? '';
    draft.vk = map['vkontakte'] ?? '';
    draft.onlineBookingUrl = map['onlineBookingUrl'] ?? '';
    
    if (map['priceList'] != null) {
      draft.priceList = (map['priceList'] as List).map((item) => Map<String, String>.from(item)).toList();
    }
    
    if (map['workMode'] != null) {
      draft.workMode = WorkMode.fromMap(map['workMode']);
    }

    return draft;
  }

  Map<String, dynamic> toMap({
    required String userId,
    String? photoUrl,
    String? postPhotoUrl,
  }) {
    return {
      'userId': userId,
      'name': name,
      'city': city,
      'category': category,
      'activityDirection': activityDirection,
      'position': position,
      'company': company,
      'tags': tags,
      'photoUrl': photoUrl,
      'description': description,
      'address': workAddress,
      'phone': phone,
      'email': email,
      'website': website,
      'telegram': telegram,
      'vkontakte': vk,
      'onlineBookingUrl': onlineBookingUrl,
      'priceList': priceList,
      'postPhotoUrl': postPhotoUrl,
      'postDescription': postDescription,
      'isActive': isActive,
      'activeUntil': activeUntil,
      'workMode': workMode.toMap(),
    };
  }
}

class WorkMode {
  String startTime = '10:00';
  String endTime = '19:00';
  List<String> workDays = []; // e.g., ["Понедельник", "Вторник"]

  WorkMode({
    this.startTime = '10:00',
    this.endTime = '19:00',
    this.workDays = const [],
  });

  factory WorkMode.fromMap(Map<String, dynamic> map) {
    return WorkMode(
      startTime: map['startTime'] ?? '10:00',
      endTime: map['endTime'] ?? '19:00',
      workDays: List<String>.from(map['workDays'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'workDays': workDays,
    };
  }
}
