import 'package:flutter/material.dart';

class BusinessCardDialog extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> cardsFuture;
  final VoidCallback onAddTap;
  final Function(Map<String, dynamic>) onCardTap;

  const BusinessCardDialog({
    super.key,
    required this.cardsFuture,
    required this.onAddTap,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 143,
          decoration: ShapeDecoration(
            color: const Color(0xFF334D50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 20,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ],
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: cardsFuture,
            builder: (context, snapshot) {
              final cards = snapshot.data ?? [];
              final isLoading = snapshot.connectionState == ConnectionState.waiting;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // List of cards
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF557578),
                          ),
                        ),
                      ),
                    )
                  else if (cards.isNotEmpty)
                    ...cards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final card = entry.value;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildItem(
                            title: card['name'] ?? 'Без названия',
                            image: card['photoUrl'],
                            onTap: () => onCardTap(card),
                            isFirst: index == 0,
                            isLast: false,
                          ),
                          const Divider(
                            height: 1,
                            color: Color(0xFFC6C6C6),
                            indent: 0,
                            endIndent: 0,
                          ),
                        ],
                      );
                    }),

                  // Add button
                  _buildItem(
                    title: 'Добавить',
                    isAdd: true,
                    onTap: onAddTap,
                    isFirst: cards.isEmpty && !isLoading,
                    isLast: true,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required String title,
    String? image,
    required VoidCallback onTap,
    bool isAdd = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(10) : Radius.zero,
        bottom: isLast ? const Radius.circular(10) : Radius.zero,
      ),
      child: Container(
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            // Icon or Image
            if (isAdd)
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8E30),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              )
            else
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF283F41),
                  image: (image != null && image.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (image == null || image.isEmpty)
                    ? const Icon(Icons.person, size: 15, color: Color(0xFF557578))
                    : null,
              ),
            const SizedBox(width: 8),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
