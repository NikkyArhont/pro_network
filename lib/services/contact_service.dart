import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ContactMatch {
  final Contact contact;
  final Map<String, dynamic>? appUser;
  final bool isRegistered;

  ContactMatch({
    required this.contact,
    this.appUser,
    required this.isRegistered,
  });
}

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'pronetwork',
  );

  /// Requests permission to access contacts
  Future<bool> requestPermission() async {
    final status = await ph.Permission.contacts.request();
    return status.isGranted;
  }

  /// Normalizes phone number for comparison (e.g., +7 900 123-45-67 -> +79001234567)
  String _normalizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Fetches phone contacts and matches them with registered users
  Future<List<ContactMatch>> getMatchedContacts() async {
    if (await FlutterContacts.permissions.request(PermissionType.read) != PermissionStatus.granted) {
      return [];
    }

    final List<Contact> contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.name, ContactProperty.phone}
    );
    final List<ContactMatch> matches = [];

    // Extract all normalized phone numbers
    final Map<String, Contact> phoneToContact = {};
    for (var contact in contacts) {
      for (var phone in contact.phones) {
        final normalized = _normalizePhoneNumber(phone.number);
        if (normalized.isNotEmpty) {
          phoneToContact[normalized] = contact;
        }
      }
    }

    if (phoneToContact.isEmpty) return [];

    // Query Firestore in chunks of 30 (Firestore limit for whereIn)
    final List<String> allPhoneNumbers = phoneToContact.keys.toList();
    final List<Map<String, dynamic>> registeredUsers = [];

    for (var i = 0; i < allPhoneNumbers.length; i += 30) {
      final chunk = allPhoneNumbers.sublist(
        i, 
        i + 30 > allPhoneNumbers.length ? allPhoneNumbers.length : i + 30
      );

      final snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', whereIn: chunk)
          .get();
      
      registeredUsers.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('uid')) data['uid'] = doc.id;
        return data;
      }));
    }

    // Build the matches list
    final Set<String> matchedPhones = {};

    // 1. Add registered users
    for (var user in registeredUsers) {
      final phone = user['phoneNumber'] as String;
      final contact = phoneToContact[phone];
      if (contact != null) {
        matches.add(ContactMatch(
          contact: contact,
          appUser: user,
          isRegistered: true,
        ));
        matchedPhones.add(phone);
      }
    }

    // 2. Add non-registered contacts (optional, but requested "телефонной книги")
    for (var entry in phoneToContact.entries) {
      if (!matchedPhones.contains(entry.key)) {
        matches.add(ContactMatch(
          contact: entry.value,
          isRegistered: false,
        ));
      }
    }

    return matches;
  }
}
