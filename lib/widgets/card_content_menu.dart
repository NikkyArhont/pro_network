import 'package:flutter/material.dart';

class CardContentMenu {
  static void show(BuildContext context, LayerLink layerLink, {
    VoidCallback? onPost,
    VoidCallback? onStory,
    VoidCallback? onOffer,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CardAddMenu',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                offset: const Offset(0, 5),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 169,
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xCC000000),
                            blurRadius: 20,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Пост
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (onPost != null) onPost();
                            },
                            child: Container(
                              width: 169,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              clipBehavior: Clip.antiAlias,
                              decoration: const ShapeDecoration(
                                color: Color(0xFF334D50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  const Icon(Icons.edit_note, color: Colors.white, size: 25),
                                  Expanded(
                                    child: Container(
                                      height: 17,
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 10,
                                        children: [
                                          SizedBox(
                                            width: 94,
                                            child: Text(
                                              'Пост',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Divider
                          Container(
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
                          ),
                          // История
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (onStory != null) onStory();
                            },
                            child: Container(
                              width: 169,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                color: Color(0xFF334D50),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 25),
                                  Expanded(
                                    child: Container(
                                      height: 17,
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 10,
                                        children: [
                                          SizedBox(
                                            width: 94,
                                            child: Text(
                                              'История',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Divider
                          Container(
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
                          ),
                          // Предложение
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (onOffer != null) onOffer();
                            },
                            child: Container(
                              width: 169,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              clipBehavior: Clip.antiAlias,
                              decoration: const ShapeDecoration(
                                color: Color(0xFF334D50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 10,
                                children: [
                                  const Icon(Icons.local_offer_outlined, color: Colors.white, size: 25),
                                  const SizedBox(
                                    width: 96,
                                    height: 17,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 10,
                                      children: [
                                        SizedBox(
                                          width: 96,
                                          child: Text(
                                            'Предложение',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
