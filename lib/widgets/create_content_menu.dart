import 'package:flutter/material.dart';
import '../screens/create_post_screen.dart';
import '../screens/create_story_screen.dart';

class CreateContentMenu {
  static void show(BuildContext context, LayerLink layerLink, {Offset offset = const Offset(0, 25)}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AddMenu',
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
                offset: offset,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {}, // Prevent dismissal when clicking the menu itself
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
                        children: [
                          // Post Option
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                              );
                            },
                            child: Container(
                              width: 169,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                children: [
                                  const Icon(Icons.edit_note, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Пост',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Separator
                          Container(width: double.infinity, height: 1, color: const Color(0xFFC6C6C6)),
                          // Story Option
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreateStoryScreen()),
                              );
                            },
                            child: Container(
                              width: 169,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                children: [
                                  const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'История',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
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
    );
  }
}
