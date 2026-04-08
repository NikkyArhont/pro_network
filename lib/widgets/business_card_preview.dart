import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pro_network/models/business_card_draft.dart';

class BusinessCardPreview extends StatelessWidget {
  final BusinessCardDraft draft;

  const BusinessCardPreview({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarImage;
    if (draft.photoPath != null) {
      avatarImage = kIsWeb 
          ? NetworkImage(draft.photoPath!) 
          : FileImage(File(draft.photoPath!)) as ImageProvider;
    } else {
      avatarImage = const NetworkImage("https://placehold.co/70x70.png");
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: const Color(0xFF0C3135),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF557578)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: avatarImage,
                    fit: BoxFit.cover,
                  ),
                  shape: const OvalBorder(),
                ),
              ),
              const SizedBox(width: 10),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.name.isEmpty ? 'Имя Фамилия' : draft.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 5,
                      children: [
                        Text(
                          draft.position.isEmpty ? 'Должность' : draft.position,
                          style: const TextStyle(
                            color: Color(0xFFC6C6C6),
                            fontSize: 12,
                          ),
                        ),
                        if (draft.company.isNotEmpty)
                          Text(
                            draft.company,
                            style: const TextStyle(
                              color: Color(0xFFC6C6C6),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${draft.category}${draft.tags.isNotEmpty ? " • " + draft.tags.join(" • ") : ""}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC6C6C6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
